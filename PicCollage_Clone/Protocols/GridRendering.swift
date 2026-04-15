import SwiftUI

/// Flattens a SwiftUI view hierarchy into a `UIImage`.
///
/// Injected into ``GridViewModel`` so that the rendering step can be
/// replaced with a `MockRenderer` during unit tests.
protocol GridRendering {
    /// Renders `view` into a `UIImage` at the given `size`.
    /// - Throws: ``GridRenderError/renderFailed`` if the underlying renderer produces no image.
    @MainActor
    func render<V: View>(_ view: V, size: CGSize) async throws -> UIImage
}

/// Errors that can be thrown during collage rendering or saving.
enum GridRenderError: Error, LocalizedError {
    case renderFailed

    var errorDescription: String? {
        switch self {
        case .renderFailed: return "Failed to render the grid image."
        }
    }
}
