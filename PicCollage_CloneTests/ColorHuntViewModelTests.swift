import Testing
import SwiftUI
import UIKit
@testable import PicCollage_Clone

/// Tests for the pure computed logic in ColorHuntViewModel.
///
/// analyze() is not tested here because it requires PHPhotoLibrary authorization.
/// suggestedTemplate(for:) is tested as a static function to verify boundary cases
/// without needing to set the private(set) rankedPhotos property.
@Suite("ColorHuntViewModel")
struct ColorHuntViewModelTests {

    // MARK: suggestedTemplate(for:)

    @Test func suggestedTemplate_zeroPhotos_returnsSingle() {
        #expect(ColorHuntViewModel.suggestedTemplate(for: 0) == .single)
    }

    @Test func suggestedTemplate_onePhoto_returnsSingle() {
        #expect(ColorHuntViewModel.suggestedTemplate(for: 1) == .single)
    }

    @Test func suggestedTemplate_twoPhotos_returnsSideBySide() {
        #expect(ColorHuntViewModel.suggestedTemplate(for: 2) == .sideBySide)
    }

    @Test func suggestedTemplate_threePhotos_returnsTopPairBottomSingle() {
        #expect(ColorHuntViewModel.suggestedTemplate(for: 3) == .topPairBottomSingle)
    }

    @Test func suggestedTemplate_fourPhotos_returnsTwoByTwo() {
        #expect(ColorHuntViewModel.suggestedTemplate(for: 4) == .twoByTwo)
    }

    @Test func suggestedTemplate_eightPhotos_returnsTwoByTwo() {
        // 8 is the upper boundary of the twoByTwo range
        #expect(ColorHuntViewModel.suggestedTemplate(for: 8) == .twoByTwo)
    }

    @Test func suggestedTemplate_ninePhotos_returnsThreeByThree() {
        #expect(ColorHuntViewModel.suggestedTemplate(for: 9) == .threeByThree)
    }

    @Test func suggestedTemplate_largeCount_returnsThreeByThree() {
        #expect(ColorHuntViewModel.suggestedTemplate(for: 100) == .threeByThree)
    }

    // MARK: topPhotos (default state)

    @MainActor
    @Test func topPhotos_emptyRankedPhotos_returnsEmpty() {
        let vm = ColorHuntViewModel()
        #expect(vm.topPhotos.isEmpty)
    }

    @MainActor
    @Test func suggestedTemplate_emptyRankedPhotos_returnsSingle() {
        let vm = ColorHuntViewModel()
        #expect(vm.suggestedTemplate == .single)
    }
}
