import Testing
import SwiftUI
import SwiftData
@testable import PicCollage_Clone

// MARK: - MockEngine

/// Stub ``GridLayoutProviding`` for unit tests.
///
/// Inject into ``GridViewModel`` to control which slots are returned
/// without depending on ``GridLayoutEngine``.
struct MockEngine: GridLayoutProviding {
    var stubbedSlots: [GridSlot] = [
        GridSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1)
    ]

    func slots(for template: GridTemplate) -> [GridSlot] { stubbedSlots }
    func columnCount(for template: GridTemplate) -> Int { 1 }
    func rowCount(for template: GridTemplate) -> Int { 1 }
}

// MARK: - MockRenderer

/// Stub ``GridRendering`` for unit tests.
///
/// Returns a system-image `UIImage` by default; set `shouldFail = true` to
/// verify error-handling paths in ``GridViewModel``.
struct MockRenderer: GridRendering {
    var shouldFail = false

    @MainActor
    func render<V: View>(_ view: V, size: CGSize) async throws -> UIImage {
        if shouldFail { throw GridRenderError.renderFailed }
        return UIImage(systemName: "photo") ?? UIImage()
    }
}

// MARK: - In-memory SwiftData container

/// Creates an in-memory `ModelContainer` for ``SavedGrid`` suitable for tests.
///
/// Using `isStoredInMemoryOnly: true` avoids touching the file system and
/// keeps each test run isolated.
func makeInMemoryContainer() throws -> ModelContainer {
    try ModelContainer(
        for: SavedGrid.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
}
