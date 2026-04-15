import Combine
import SwiftUI
import SwiftData
import Photos

/// Drives the collage editor screen.
///
/// `GridViewModel` is the single source of truth for:
/// - which ``GridTemplate`` is active,
/// - the ordered array of ``GridPhoto`` values the user has picked,
/// - the derived `cells` array that the grid view renders,
/// - async save/load operations.
///
/// All mutations happen on the main actor so `@Published` updates are
/// always delivered on the main thread.
@MainActor
final class GridViewModel: ObservableObject {

    // MARK: Published state

    /// Ordered (slot, photo?) pairs ready for the grid view to render.
    @Published private(set) var cells: [(slot: GridSlot, photo: GridPhoto?)] = []

    /// The active layout template. Changing it rebuilds the cells array immediately.
    @Published var template: GridTemplate = .single {
        didSet { recomputeCells() }
    }

    /// Currently selected canvas aspect ratio.
    @Published var aspectRatio: GridAspectRatio = .square

    /// `true` while the async save operation is in-flight.
    @Published private(set) var isSaving: Bool = false

    // MARK: Internal state

    private(set) var photos: [GridPhoto] = []
    private let engine: GridLayoutProviding
    private let renderer: GridRendering

    // MARK: Init

    /// - Parameters:
    ///   - engine: Layout engine; defaults to ``GridLayoutEngine``.
    ///   - renderer: Render engine; defaults to ``GridRenderer``.
    init(
        engine: GridLayoutProviding = GridLayoutEngine(),
        renderer: GridRendering = GridRenderer()
    ) {
        self.engine = engine
        self.renderer = renderer
        recomputeCells()
    }

    // MARK: Public API

    /// Replaces all photos and recomputes cells.
    func update(photos: [GridPhoto]) {
        self.photos = photos
        recomputeCells()
    }

    /// Changes the active template and recomputes cells.
    func update(template: GridTemplate) {
        self.template = template
    }

    /// Replaces the photo in slot `index` with `photo`.
    func replacePhoto(at index: Int, with photo: GridPhoto) {
        guard index >= 0 else { return }
        if index < photos.count {
            photos[index] = photo
        } else {
            while photos.count < index {
                photos.append(photos.last ?? photo)
            }
            photos.append(photo)
        }
        recomputeCells()
    }

    /// Renders `gridView` into a JPEG, persists a ``SavedGrid`` record via
    /// SwiftData, and saves the image to the user's photo library.
    /// - Parameters:
    ///   - gridView: The live `GridView` to flatten.
    ///   - context: The SwiftData `ModelContext` to insert the record into.
    func save(gridView: some View, context: ModelContext) async throws {
        isSaving = true
        defer { isSaving = false }

        let uiImage = try await renderer.render(gridView, size: aspectRatio.renderSize)

        guard let thumbnailData = uiImage.jpegData(compressionQuality: 0.85) else {
            throw GridRenderError.renderFailed
        }

        let photoData = photos.map { $0.imageData }
        let record = SavedGrid(template: template, aspectRatio: aspectRatio, photoData: photoData, thumbnailData: thumbnailData)
        context.insert(record)

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
        }
    }

    /// Restores a previously saved collage into the editor.
    func load(from collage: SavedGrid) {
        let loadedPhotos: [GridPhoto] = collage.photoData.compactMap { data in
            guard let uiImage = UIImage(data: data) else { return nil }
            return GridPhoto(image: Image(uiImage: uiImage), imageData: data)
        }
        let loadedTemplate = GridTemplate(rawValue: collage.templateRawValue) ?? .single
        let loadedAspectRatio = GridAspectRatio(rawValue: collage.aspectRatioRawValue) ?? .square
        self.photos = loadedPhotos
        self.template = loadedTemplate
        self.aspectRatio = loadedAspectRatio
        recomputeCells()
    }

    /// The number of columns in the current template's grid.
    var columnCount: Int { engine.columnCount(for: template) }

    /// The number of rows in the current template's grid.
    var rowCount: Int { engine.rowCount(for: template) }

    // MARK: Private

    private func recomputeCells() {
        let slots = engine.slots(for: template)
        cells = slots.map { slot in
            let photo = slot.id < photos.count ? photos[slot.id] : nil
            return (slot: slot, photo: photo)
        }
    }
}
