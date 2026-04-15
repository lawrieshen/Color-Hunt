import SwiftUI

/// A thumbnail card representing one ``SavedCollage`` in the Library grid.
///
/// Displays the flattened thumbnail JPEG and a formatted date below it.
/// Uses `@ViewBuilder` to gracefully fall back to a placeholder when the
/// thumbnail data cannot be decoded.
struct SavedCollageCardView: View {

    let collage: SavedCollage

    /// Called when the user taps the card.
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            thumbnailImage
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .cornerRadius(8)

            Text(collage.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .accessibilityIdentifier("collageCard")
    }

    /// Decoded thumbnail image, or a grey placeholder if decoding fails.
    @ViewBuilder
    private var thumbnailImage: some View {
        if let uiImage = UIImage(data: collage.thumbnailData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Rectangle()
                .fill(Color(.systemGray5))
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
        }
    }
}
