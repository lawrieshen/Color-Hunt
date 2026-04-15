import Foundation
import SwiftData

/// A persisted collage record stored via SwiftData.
///
/// Binary photo blobs are stored with `@Attribute(.externalStorage)` so that
/// the underlying SQLite row stays small — SwiftData writes the bytes to an
/// external file managed alongside the store.
@Model
final class SavedCollage {

    /// Stable identifier for this collage.
    var id: UUID

    /// Raw value of the ``CollageLayoutTemplate`` used when the collage was saved.
    var templateRawValue: Int

    /// JPEG-encoded data for each filled photo slot, in slot order.
    @Attribute(.externalStorage)
    var photoData: [Data]

    /// JPEG of the full flattened collage image shown as a thumbnail in the Library.
    @Attribute(.externalStorage)
    var thumbnailData: Data

    /// Raw value of the ``CollageAspectRatio`` used when the collage was saved.
    /// Defaults to ``CollageAspectRatio/square`` for records created before this field existed.
    var aspectRatioRawValue: Int = CollageAspectRatio.square.rawValue

    /// When this collage was saved. Used for reverse-chronological Library sorting.
    var createdAt: Date

    init(template: CollageLayoutTemplate, aspectRatio: CollageAspectRatio, photoData: [Data], thumbnailData: Data) {
        self.id = UUID()
        self.templateRawValue = template.rawValue
        self.aspectRatioRawValue = aspectRatio.rawValue
        self.photoData = photoData
        self.thumbnailData = thumbnailData
        self.createdAt = Date()
    }
}
