import SwiftUI
import UIKit

/// A photo candidate produced by ``ColorHuntViewModel``.
///
/// Holds everything needed to display the photo in the grid and to
/// convert it to a ``CollagePhoto`` when handing off to the Create tab.
struct ColorHuntPhoto: Identifiable, Equatable {

    static func == (lhs: ColorHuntPhoto, rhs: ColorHuntPhoto) -> Bool {
        lhs.id == rhs.id
    }


    /// Stable identifier for diffing inside `ForEach`.
    let id: UUID

    /// SwiftUI image for display in the collage grid.
    let image: Image

    /// JPEG-encoded backing bytes for ``CollagePhoto`` handoff.
    let imageData: Data

    /// The dominant color of this photo, determined by k-means clustering in ``ColorAnalysisEngine``.
    let dominantColor: UIColor

    /// Euclidean RGB distance to the user's target color. Lower = closer match.
    let colorDistance: CGFloat

    /// Converts this candidate into a ``CollagePhoto`` for the Create tab.
    func asCollagePhoto() -> CollagePhoto {
        CollagePhoto(image: image, imageData: imageData)
    }
}
