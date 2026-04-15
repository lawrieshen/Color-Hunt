import Foundation

// MARK: - GridTemplate

/// Supported collage grid configurations.
///
/// The raw value equals the number of photo slots the template provides,
/// which is also the `maxSelectionCount` passed to `PhotosPicker`.
enum GridTemplate: Int, CaseIterable, Identifiable {
    case single = 1
    case sideBySide = 2
    case topPairBottomSingle = 3
    case twoByTwo = 4
    case threeByThree = 5
    
    var id: Int { rawValue }
    
    /// Human-readable label shown in the segmented picker.
    var displayName: String {
        switch self {
        case .single: return "1 × 1"
        case .sideBySide: return "1 × 2"
        case .topPairBottomSingle: return "2 + 1" // Indicates 2 top slots + 1 bottom span
        case .twoByTwo: return "2 × 2"
        case .threeByThree: return "3 × 3"
        }
    }
}

// MARK: - GridAspectRatio

/// Supported canvas aspect ratios for the collage grid.
///
/// The `value` property expresses width ÷ height; `renderSize` gives the
/// corresponding output dimensions with a 1024pt long side.
enum GridAspectRatio: Int, CaseIterable, Identifiable {
    case square = 1 // 1:1
    case portrait = 2 // 3:4
    case landscape = 3 // 4:3
    case story = 4 // 9:16 — Instagram Story / TikTok
    
    var id: Int { rawValue }
    
    /// Width-to-height ratio used by the grid layout and renderer.
    var value: CGFloat {
        switch self {
        case .square: return 1
        case .portrait: return 3.0 / 4.0
        case .landscape: return 4.0 / 3.0
        case .story: return 9.0 / 16.0
        }
    }
    
    /// Label shown in the aspect ratio picker.
    var displayName: String {
        switch self {
        case .square: return "1:1"
        case .portrait: return "3:4"
        case .landscape: return "4:3"
        case .story: return "9:16"
        }
    }
    
    /// Output image size for saving, with the long side fixed at 1024pt.
    var renderSize: CGSize {
        let side: CGFloat = 1024
        return value >= 1
        ? CGSize(width: side, height: side / value)
        : CGSize(width: side * value, height: side)
    }
}

// MARK: - GridSlot

/// Describes one cell's position and span within a grid.
struct GridSlot: Identifiable {
    let id: Int
    let row: Int
    let column: Int
    let columnSpan: Int
    let rowSpan: Int
}

// MARK: - GridLayoutProviding

/// Computes the slot geometry for a given ``GridTemplate``.
///
/// Conforming types are injected into ``GridViewModel``, enabling
/// the layout engine to be swapped or mocked in tests without touching the VM.
protocol GridLayoutProviding {
    /// Returns the ordered list of slots for `template`.
    func slots(for template: GridTemplate) -> [GridSlot]
    /// Returns the total number of columns in `template`'s grid.
    func columnCount(for template: GridTemplate) -> Int
    /// Returns the total number of rows in `template`'s grid.
    func rowCount(for template: GridTemplate) -> Int
}
