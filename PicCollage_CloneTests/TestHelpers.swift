import Testing
import SwiftUI
import SwiftData
@testable import PicCollage_Clone

// MARK: - MockEngine

/// Stub ``CollageLayoutProviding`` for unit tests.
///
/// Inject into ``CollageLayoutViewModel`` to control which slots are returned
/// without depending on ``CollageLayoutEngine``.
struct MockEngine: CollageLayoutProviding {
    var stubbedSlots: [CollageLayoutSlot] = [
        CollageLayoutSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1)
    ]

    func slots(for template: CollageLayoutTemplate) -> [CollageLayoutSlot] { stubbedSlots }
    func columnCount(for template: CollageLayoutTemplate) -> Int { 1 }
    func rowCount(for template: CollageLayoutTemplate) -> Int { 1 }
}

// MARK: - MockRenderer

/// Stub ``CollageRendering`` for unit tests.
///
/// Returns a system-image `UIImage` by default; set `shouldFail = true` to
/// verify error-handling paths in ``CollageLayoutViewModel``.
struct MockRenderer: CollageRendering {
    var shouldFail = false

    @MainActor
    func render<V: View>(_ view: V, size: CGSize) async throws -> UIImage {
        if shouldFail { throw CollageRenderError.renderFailed }
        return UIImage(systemName: "photo") ?? UIImage()
    }
}

// MARK: - In-memory SwiftData container

/// Creates an in-memory `ModelContainer` for ``SavedCollage`` suitable for tests.
///
/// Using `isStoredInMemoryOnly: true` avoids touching the file system and
/// keeps each test run isolated.
func makeInMemoryContainer() throws -> ModelContainer {
    try ModelContainer(
        for: SavedCollage.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
}
