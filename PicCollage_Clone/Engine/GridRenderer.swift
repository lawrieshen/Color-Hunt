import SwiftUI

/// Concrete ``GridRendering`` implementation backed by SwiftUI's `ImageRenderer`.
///
/// `ImageRenderer` must be created and used on the main actor, which is why
/// the entire `render(_:size:)` method is `@MainActor`.
struct GridRenderer: GridRendering {

    nonisolated init() {}

    @MainActor
    func render<V: View>(_ view: V, size: CGSize) async throws -> UIImage {
        let renderer = ImageRenderer(content:
            view.frame(width: size.width, height: size.height)
        )
        renderer.scale = UITraitCollection.current.displayScale

        guard let uiImage = renderer.uiImage else {
            throw GridRenderError.renderFailed
        }
        return uiImage
    }
}
