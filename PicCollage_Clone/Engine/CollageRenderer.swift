import SwiftUI

/// Concrete ``CollageRendering`` implementation backed by SwiftUI's `ImageRenderer`.
///
/// `ImageRenderer` must be created and used on the main actor, which is why
/// the entire `render(_:size:)` method is `@MainActor`.
struct CollageRenderer: CollageRendering {

    nonisolated init() {}

    @MainActor
    func render<V: View>(_ view: V, size: CGSize) async throws -> UIImage {
        let renderer = ImageRenderer(content:
            view.frame(width: size.width, height: size.height)
        )
        renderer.scale = UITraitCollection.current.displayScale

        guard let uiImage = renderer.uiImage else {
            throw CollageRenderError.renderFailed
        }
        return uiImage
    }
}
