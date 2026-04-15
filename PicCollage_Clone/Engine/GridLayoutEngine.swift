import Foundation

/// Concrete ``GridLayoutProviding`` implementation.
///
/// Encodes the slot geometry for every ``GridTemplate``.
/// In tests, pass a custom conforming type to verify layout logic without
/// this implementation.
struct GridLayoutEngine: GridLayoutProviding {
    
    nonisolated init() {}
    
    func slots(for template: GridTemplate) -> [GridSlot] {
        switch template {
        case .single:
            return [
                GridSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1)
            ]
            
        case .sideBySide:
            return [
                GridSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 1, row: 0, column: 1, columnSpan: 1, rowSpan: 1)
            ]
            
        case .topPairBottomSingle:
            return [
                GridSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 1, row: 0, column: 1, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 2, row: 1, column: 0, columnSpan: 2, rowSpan: 1)
            ]
            
        case .twoByTwo:
            return [
                GridSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 1, row: 0, column: 1, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 2, row: 1, column: 0, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 3, row: 1, column: 1, columnSpan: 1, rowSpan: 1)
            ]
            
        case .threeByThree:
            return [
                GridSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 1, row: 0, column: 1, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 2, row: 0, column: 2, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 3, row: 1, column: 0, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 4, row: 1, column: 1, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 5, row: 1, column: 2, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 6, row: 2, column: 0, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 7, row: 2, column: 1, columnSpan: 1, rowSpan: 1),
                GridSlot(id: 8, row: 2, column: 2, columnSpan: 1, rowSpan: 1)
            ]
        }
    }
    
    func columnCount(for template: GridTemplate) -> Int {
        switch template {
        case .single: return 1
        case .sideBySide: return 2
        case .topPairBottomSingle: return 2
        case .twoByTwo: return 2
        case .threeByThree: return 3
        }
    }
    
    func rowCount(for template: GridTemplate) -> Int {
        switch template {
        case .single: return 1
        case .sideBySide: return 1
        case .topPairBottomSingle: return 2
        case .twoByTwo: return 2
        case .threeByThree: return 3
        }
    }
}
