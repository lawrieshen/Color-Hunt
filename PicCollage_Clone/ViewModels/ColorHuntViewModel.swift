import SwiftUI
import Photos
import Combine

/// Async semaphore that suspends Swift tasks instead of blocking threads.
/// Used to cap concurrent PHImageManager requests and avoid memory pressure.
private actor AsyncSemaphore {
    private var available: Int
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(_ count: Int) { available = count }

    func wait() async {
        if available > 0 { available -= 1; return }
        await withCheckedContinuation { waiters.append($0) }
    }

    func signal() {
        if let next = waiters.first {
            waiters.removeFirst()
            next.resume()
        } else {
            available += 1
        }
    }
}

/// Drives the Color Hunt screen.
///
/// Fetches photos taken in the past 30 days, computes each photo's dominant
/// color via ``ColorHuntProviding``, and ranks them by closeness to the
/// user-chosen ``targetColor``.
@MainActor
final class ColorHuntViewModel: ObservableObject {

    // MARK: Published state

    /// The color the user wants to hunt for. Drives the ranking on each analysis run.
    @Published var targetColor: Color = .orange

    /// Photos sorted by distance to ``targetColor`` (closest first).
    @Published private(set) var rankedPhotos: [ColorHuntPhoto] = []

    /// `true` while fetching and analysing photos.
    @Published private(set) var isAnalyzing: Bool = false

    /// `true` if the user denied photo library access.
    @Published private(set) var accessDenied: Bool = false

    // MARK: Dependency

    private let engine: ColorHuntProviding

    /// - Parameter engine: Color analysis strategy; defaults to ``ColorAnalysisEngine``.
    init(engine: ColorHuntProviding = ColorAnalysisEngine()) {
        self.engine = engine
    }

    // MARK: Computed

    /// The best-fit layout template for the number of matched photos available.
    var suggestedTemplate: GridTemplate {
        Self.suggestedTemplate(for: rankedPhotos.count)
    }

    /// Maps a photo count to the most appropriate layout template.
    /// Extracted as a static function so it can be tested independently.
    nonisolated static func suggestedTemplate(for photoCount: Int) -> GridTemplate {
        switch photoCount {
        case 0, 1: return .single
        case 2: return .sideBySide
        case 3: return .topPairBottomSingle
        case 4...8: return .twoByTwo
        default: return .threeByThree
        }
    }

    /// How many slots the suggested template actually holds.
    private static func slotCount(for template: GridTemplate) -> Int {
        switch template {
        case .single: return 1
        case .sideBySide: return 2
        case .topPairBottomSingle: return 3
        case .twoByTwo: return 4
        case .threeByThree: return 9
        }
    }

    /// The top N photos that fill the suggested template — ready to send to Create.
    var topPhotos: [ColorHuntPhoto] {
        Array(rankedPhotos.prefix(Self.slotCount(for: suggestedTemplate)))
    }

    // MARK: Public API

    /// Requests photo library access, fetches the past 30 days, analyses dominant
    /// colors concurrently, and updates ``rankedPhotos``.
    func analyze() async {
        isAnalyzing = true
        defer { isAnalyzing = false }
        accessDenied = false

        // 1. Authorization
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized || status == .limited else {
            accessDenied = true
            return
        }

        // 2. Fetch assets from the last 30 days
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "creationDate > %@", sevenDaysAgo as CVarArg)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: .image, options: options)

        var assets: [PHAsset] = []
        fetchResult.enumerateObjects { asset, _, _ in assets.append(asset) }
        guard !assets.isEmpty else { return }

        // 3. Analyse concurrently off the main actor, capped at 4 simultaneous fetches
        //    to prevent memory exhaustion when the library is large.
        let uiTarget = UIColor(targetColor)
        let engineRef = engine
        let semaphore = AsyncSemaphore(4)

        let results = await Task.detached(priority: .userInitiated) {
            await withTaskGroup(of: ColorHuntPhoto?.self) { group in
                for asset in assets {
                    group.addTask {
                        await semaphore.wait()
                        defer { Task { await semaphore.signal() } }
                        return await Self.analyzeAsset(asset, targetColor: uiTarget, engine: engineRef)
                    }
                }
                var photos: [ColorHuntPhoto] = []
                for await photo in group {
                    if let photo { photos.append(photo) }
                }
                return photos
            }
        }.value

        // 4. Sort closest-first, keep only the top 9 — the grid never shows more.
        //    Discarding the rest releases their imageData and backing UIImages.
        rankedPhotos = Array(results.sorted { $0.colorDistance < $1.colorDistance }.prefix(9))
    }

    // MARK: Private

    /// Fetches a small thumbnail for color analysis and a display-quality image
    /// for the collage — both concurrently. Returns `nil` if either fetch fails.
    private static func analyzeAsset(
        _ asset: PHAsset,
        targetColor: UIColor,
        engine: any ColorHuntProviding
    ) async -> ColorHuntPhoto? {

        // Launch both fetches concurrently
        async let thumbnail = fetchImage(asset: asset,
                                         targetSize: CGSize(width: 100, height: 100),
                                         deliveryMode: .fastFormat,
                                         resizeMode: .fast,
                                         networkAccess: false)
        async let fullImage = fetchImage(asset: asset,
                                         targetSize: CGSize(width: 1200, height: 1200),
                                         deliveryMode: .highQualityFormat,
                                         resizeMode: .exact,
                                         networkAccess: true)

        guard let thumb = await thumbnail,
              let full  = await fullImage else { return nil }

        let dominant = engine.dominantColor(for: thumb)
        let distance = dominant.distance(to: targetColor)
        let jpegData = full.jpegData(compressionQuality: 0.85) ?? Data()
        // Build Image from the compressed JPEG so the raw pixel buffer in `full` can release.
        let swiftUIImage = await MainActor.run { Image(uiImage: UIImage(data: jpegData) ?? UIImage()) }

        return ColorHuntPhoto(
            id:            UUID(),
            image:         swiftUIImage,
            imageData:     jpegData,
            dominantColor: dominant,
            colorDistance: distance
        )
    }

    private static func fetchImage(
        asset: PHAsset,
        targetSize: CGSize,
        deliveryMode: PHImageRequestOptionsDeliveryMode,
        resizeMode: PHImageRequestOptionsResizeMode,
        networkAccess: Bool
    ) async -> UIImage? {
        // Box lets the cancellation handler reach the request ID captured inside the continuation.
        final class Box: @unchecked Sendable { var value: PHImageRequestID = PHInvalidImageRequestID }
        let box = Box()

        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                let opts = PHImageRequestOptions()
                opts.deliveryMode = deliveryMode
                opts.resizeMode = resizeMode
                opts.isNetworkAccessAllowed = networkAccess

                var didResume = false
                box.value = PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: opts
                ) { image, _ in
                    guard !didResume else { return }
                    didResume = true
                    continuation.resume(returning: image)
                }
            }
        } onCancel: {
            PHImageManager.default().cancelImageRequest(box.value)
        }
    }
}
