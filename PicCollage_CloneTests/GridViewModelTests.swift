import Testing
import SwiftUI
import SwiftData
@testable import PicCollage_Clone

@MainActor
@Suite("GridViewModel")
struct GridViewModelTests {

    // MARK: Helpers

    private func makePhoto() -> GridPhoto {
        let data = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }.jpegData(compressionQuality: 0.85) ?? Data()
        return GridPhoto(image: Image(systemName: "photo"), imageData: data)
    }

    // MARK: update(photos:)

    @Test func updatePhotos_storesPhotos() {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())
        let photos = [makePhoto(), makePhoto()]
        vm.update(photos: photos)
        #expect(vm.photos.count == 2)
    }

    @Test func updatePhotos_recomputesCells() {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())
        vm.update(photos: [makePhoto()])
        // MockEngine returns 1 slot, so cells always has 1 entry
        #expect(vm.cells.count == 1)
    }

    @Test func updatePhotos_emptyArray_leavesAllCellsWithNilPhoto() {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())
        vm.update(photos: [])
        #expect(vm.cells.allSatisfy { $0.photo == nil })
    }

    // MARK: update(template:)

    @Test func updateTemplate_changesTemplateProperty() {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())
        vm.update(template: .twoByTwo)
        #expect(vm.template == .twoByTwo)
    }

    @Test func columnAndRowCount_delegateToEngine() {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())
        // MockEngine always returns 1 for both
        #expect(vm.columnCount == 1)
        #expect(vm.rowCount == 1)
    }

    // MARK: replacePhoto(at:with:)

    @Test func replacePhoto_inBounds_replacesCorrectElement() {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())
        let original = makePhoto()
        let replacement = makePhoto()
        vm.update(photos: [original])
        vm.replacePhoto(at: 0, with: replacement)
        #expect(vm.photos[0] == replacement)
    }

    @Test func replacePhoto_negativeIndex_isIgnored() {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())
        let photo = makePhoto()
        vm.update(photos: [photo])
        vm.replacePhoto(at: -1, with: makePhoto())
        #expect(vm.photos.count == 1)
        #expect(vm.photos[0] == photo)
    }

    @Test func replacePhoto_outOfBoundsIndex_growsArray() {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())
        let original = makePhoto()
        let extra = makePhoto()
        vm.update(photos: [original])
        // Replacing at index 2 pads index 1 with the last photo, then appends extra
        vm.replacePhoto(at: 2, with: extra)
        #expect(vm.photos.count == 3)
        #expect(vm.photos[2] == extra)
    }

    // MARK: load(from:)

    @Test func load_restoresTemplateAndAspectRatio() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())

        let collage = SavedGrid(
            template: .twoByTwo,
            aspectRatio: .landscape,
            photoData: [makePhoto().imageData],
            thumbnailData: makePhoto().imageData
        )
        context.insert(collage)

        vm.load(from: collage)

        #expect(vm.template == .twoByTwo)
        #expect(vm.aspectRatio == .landscape)
    }

    @Test func load_invalidRawValues_fallBackToDefaults() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())

        let collage = SavedGrid(
            template: .single,
            aspectRatio: .square,
            photoData: [],
            thumbnailData: Data()
        )
        collage.templateRawValue = 999
        collage.aspectRatioRawValue = 999
        context.insert(collage)

        vm.load(from: collage)

        #expect(vm.template == .single)    // fallback
        #expect(vm.aspectRatio == .square) // fallback
    }

    @Test func load_skipsInvalidPhotoData() throws {
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer())

        let collage = SavedGrid(
            template: .single,
            aspectRatio: .square,
            photoData: [Data(), Data()], // invalid JPEG bytes — compactMap drops them
            thumbnailData: Data()
        )
        context.insert(collage)

        vm.load(from: collage)

        #expect(vm.photos.isEmpty)
    }

    // MARK: save(gridView:context:)

    @Test func save_rendererFailure_throwsRenderFailed() async throws {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer(shouldFail: true))
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        await #expect(throws: GridRenderError.renderFailed) {
            try await vm.save(gridView: EmptyView(), context: context)
        }
    }

    @Test func save_isSavingReturnsFalseAfterRendererFailure() async throws {
        let vm = GridViewModel(engine: MockEngine(), renderer: MockRenderer(shouldFail: true))
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)

        try? await vm.save(gridView: EmptyView(), context: context)

        #expect(vm.isSaving == false)
    }

    @Test func save_insertsCollageIntoContext() async throws {
        let vm = GridViewModel(engine: MockEngine(), renderer: SolidImageRenderer())
        let container = try makeInMemoryContainer()
        let context = ModelContext(container)
        vm.update(photos: [makePhoto()])

        // PHPhotoLibrary throws in a test environment — suppress it and check the insert
        try? await vm.save(gridView: EmptyView(), context: context)

        let collages = try context.fetch(FetchDescriptor<SavedGrid>())
        #expect(collages.count == 1)
    }
}

// MARK: - SolidImageRenderer

/// Renderer that returns a 1×1 red image without touching SwiftUI layout.
/// Used in tests that need a non-nil UIImage with valid JPEG data.
private struct SolidImageRenderer: GridRendering {
    @MainActor
    func render<V: View>(_ view: V, size: CGSize) async throws -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }
}
