import SwiftUI

/// A single photo slot in an in-memory grid session.
///
/// `GridPhoto` is a pure value type used only while the user is editing.
/// It is never persisted directly; call ``imageData`` to obtain the JPEG
/// bytes that are written to ``SavedGrid`` on save.
struct GridPhoto: Identifiable, Equatable {

    /// Stable identifier used to diff cells in the ViewModel.
    let id: UUID

    /// SwiftUI image ready for display.
    let image: Image

    /// JPEG-encoded backing bytes. Written to ``SavedGrid/photoData`` when saving.
    let imageData: Data

    /// Creates a `GridPhoto` from a decoded image and its raw JPEG data.
    /// - Parameters:
    ///   - id: Stable identifier; defaults to a new `UUID`.
    ///   - image: SwiftUI `Image` for display.
    ///   - imageData: JPEG `Data` for persistence.
    init(id: UUID = UUID(), image: Image, imageData: Data) {
        self.id = id
        self.image = image
        self.imageData = imageData
    }

    static func == (lhs: GridPhoto, rhs: GridPhoto) -> Bool {
        lhs.id == rhs.id
    }
}
