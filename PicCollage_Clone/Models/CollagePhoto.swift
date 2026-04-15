import SwiftUI

/// A single photo slot in an in-memory collage session.
///
/// `CollagePhoto` is a pure value type used only while the user is editing.
/// It is never persisted directly; call ``imageData`` to obtain the JPEG
/// bytes that are written to ``SavedCollage`` on save.
struct CollagePhoto: Identifiable, Equatable {

    /// Stable identifier used to diff cells in the ViewModel.
    let id: UUID

    /// SwiftUI image ready for display.
    let image: Image

    /// JPEG-encoded backing bytes. Written to ``SavedCollage/photoData`` when saving.
    let imageData: Data

    /// Creates a `CollagePhoto` from a decoded image and its raw JPEG data.
    /// - Parameters:
    ///   - id: Stable identifier; defaults to a new `UUID`.
    ///   - image: SwiftUI `Image` for display.
    ///   - imageData: JPEG `Data` for persistence.
    init(id: UUID = UUID(), image: Image, imageData: Data) {
        self.id = id
        self.image = image
        self.imageData = imageData
    }

    static func == (lhs: CollagePhoto, rhs: CollagePhoto) -> Bool {
        lhs.id == rhs.id
    }
}
