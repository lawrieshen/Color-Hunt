import Foundation

/// Concrete ``CollageLayoutProviding`` implementation.
///
/// Encodes the slot geometry for every ``CollageLayoutTemplate``.
/// In tests, pass a custom conforming type to verify layout logic without
/// this implementation.
struct CollageLayoutEngine: CollageLayoutProviding {
    
    nonisolated init() {}
    
    func slots(for template: CollageLayoutTemplate) -> [CollageLayoutSlot] {
        switch template {
        case .single:
            return [
                CollageLayoutSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1)
            ]
            
        case .sideBySide:
            return [
                CollageLayoutSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 1, row: 0, column: 1, columnSpan: 1, rowSpan: 1)
            ]
            
        case .topPairBottomSingle:
            return [
                CollageLayoutSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 1, row: 0, column: 1, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 2, row: 1, column: 0, columnSpan: 2, rowSpan: 1)
            ]
            
        case .twoByTwo:
            return [
                CollageLayoutSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 1, row: 0, column: 1, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 2, row: 1, column: 0, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 3, row: 1, column: 1, columnSpan: 1, rowSpan: 1)
            ]
            
        case .threeByThree:
            return [
                CollageLayoutSlot(id: 0, row: 0, column: 0, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 1, row: 0, column: 1, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 2, row: 0, column: 2, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 3, row: 1, column: 0, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 4, row: 1, column: 1, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 5, row: 1, column: 2, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 6, row: 2, column: 0, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 7, row: 2, column: 1, columnSpan: 1, rowSpan: 1),
                CollageLayoutSlot(id: 8, row: 2, column: 2, columnSpan: 1, rowSpan: 1)
            ]
        }
    }
    
    func columnCount(for template: CollageLayoutTemplate) -> Int {
        switch template {
        case .single: return 1
        case .sideBySide: return 2
        case .topPairBottomSingle: return 2
        case .twoByTwo: return 2
        case .threeByThree: return 3
        }
    }
    
    func rowCount(for template: CollageLayoutTemplate) -> Int {
        switch template {
        case .single: return 1
        case .sideBySide: return 1
        case .topPairBottomSingle: return 2
        case .twoByTwo: return 2
        case .threeByThree: return 3
        }
    }
}
