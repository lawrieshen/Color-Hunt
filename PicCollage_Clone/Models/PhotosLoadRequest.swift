import Foundation

/// Carries a set of photos and a layout template from ``ColorHuntView`` to ``CreateView``.
///
/// Wrapping the payload in a struct (rather than a tuple) lets it conform to
/// `Equatable`, which is required for SwiftUI's `onChange(of:)`.
struct PhotosLoadRequest: Equatable {
    let photos: [GridPhoto]
    let template: GridTemplate
}
