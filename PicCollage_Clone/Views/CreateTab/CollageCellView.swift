import SwiftUI

/// A single tappable cell inside the collage grid.
///
/// Uses `@ViewBuilder` to branch between a filled photo and a grey placeholder,
/// keeping each state self-contained and easy to style independently.
struct CollageCellView: View {

    /// The photo to display, or `nil` to show the placeholder.
    let photo: CollagePhoto?

    /// Zero-based index of this cell within the grid. Forwarded to `onTap`.
    let index: Int

    /// Called when the user taps the cell, passing the cell's `index`.
    let onTap: (Int) -> Void

    var body: some View {
        ZStack {
            if let photo {
                photoView(photo)
            } else {
                placeholderView
            }
        }
        .clipped()                          // clip after the frame is set by the parent
        .contentShape(Rectangle())
        .onTapGesture { onTap(index) }
        .accessibilityIdentifier("collageCell_\(index)")
    }

    /// Displays the user's photo, filling the cell and clipping overflow.
    @ViewBuilder
    private func photoView(_ photo: CollagePhoto) -> some View {
        Color.clear
            .overlay(
                photo.image
                    .resizable()
                    .scaledToFill()
            )
            .clipped()
    }

    /// Grey background with a photo icon; shown until the user picks an image.
    private var placeholderView: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
    }
}
