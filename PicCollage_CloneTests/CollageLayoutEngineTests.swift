import Testing
@testable import PicCollage_Clone

@Suite("CollageLayoutEngine")
struct CollageLayoutEngineTests {

    private let engine = CollageLayoutEngine()

    // MARK: Slot counts

    @Test func singleTemplate_hasOneSlot() {
        #expect(engine.slots(for: .single).count == 1)
    }

    @Test func sideBySideTemplate_hasTwoSlots() {
        #expect(engine.slots(for: .sideBySide).count == 2)
    }

    @Test func topPairBottomSingleTemplate_hasThreeSlots() {
        #expect(engine.slots(for: .topPairBottomSingle).count == 3)
    }

    @Test func twoByTwoTemplate_hasFourSlots() {
        #expect(engine.slots(for: .twoByTwo).count == 4)
    }

    @Test func threeByThreeTemplate_hasNineSlots() {
        #expect(engine.slots(for: .threeByThree).count == 9)
    }

    // MARK: Column counts

    @Test func columnCounts_matchExpected() {
        #expect(engine.columnCount(for: .single) == 1)
        #expect(engine.columnCount(for: .sideBySide) == 2)
        #expect(engine.columnCount(for: .topPairBottomSingle) == 2)
        #expect(engine.columnCount(for: .twoByTwo) == 2)
        #expect(engine.columnCount(for: .threeByThree) == 3)
    }

    // MARK: Row counts

    @Test func rowCounts_matchExpected() {
        #expect(engine.rowCount(for: .single) == 1)
        #expect(engine.rowCount(for: .sideBySide) == 1)
        #expect(engine.rowCount(for: .topPairBottomSingle) == 2)
        #expect(engine.rowCount(for: .twoByTwo) == 2)
        #expect(engine.rowCount(for: .threeByThree) == 3)
    }

    // MARK: Slot geometry

    @Test func topPairBottomSingle_bottomSlotSpansTwoColumns() throws {
        let slots = engine.slots(for: .topPairBottomSingle)
        let bottomSlot = try #require(slots.last)
        #expect(bottomSlot.columnSpan == 2)
        #expect(bottomSlot.row == 1)
    }

    @Test func allTemplates_slotIdsAreSequential() {
        for template in CollageLayoutTemplate.allCases {
            let slots = engine.slots(for: template)
            #expect(slots.map(\.id) == Array(0..<slots.count))
        }
    }
}
