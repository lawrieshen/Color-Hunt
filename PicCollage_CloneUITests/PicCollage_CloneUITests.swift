import XCTest

final class PicCollage_CloneUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - App Launch & Tab Navigation

    func testAppLaunchShowsCreateTab() {
        XCTAssertTrue(app.navigationBars["Create"].exists)
    }

    func testTapLibraryTab_showsLibraryScreen() {
        app.tabBars.buttons["Library"].tap()
        XCTAssertTrue(app.navigationBars["Library"].waitForExistence(timeout: 2))
    }

    func testTapColorHuntTab_showsColorHuntScreen() {
        app.tabBars.buttons["Color Hunt"].tap()
        XCTAssertTrue(app.navigationBars["Color Hunt"].waitForExistence(timeout: 2))
    }

    func testTapBackToCreateTab_showsCreateScreen() {
        app.tabBars.buttons["Library"].tap()
        app.tabBars.buttons["Create"].tap()
        XCTAssertTrue(app.navigationBars["Create"].waitForExistence(timeout: 2))
    }

    // MARK: - Create Tab: Template Picker

    func testTemplatePicker_exists() {
        XCTAssertTrue(app.segmentedControls["templatePicker"].exists)
    }

    func testTemplatePicker_allSegmentsPresent() {
        let picker = app.segmentedControls["templatePicker"]
        XCTAssertTrue(picker.buttons["1 × 1"].exists)
        XCTAssertTrue(picker.buttons["1 × 2"].exists)
        XCTAssertTrue(picker.buttons["2 + 1"].exists)
        XCTAssertTrue(picker.buttons["2 × 2"].exists)
        XCTAssertTrue(picker.buttons["3 × 3"].exists)
    }

    func testTemplatePicker_selectTwoByTwo_showsFourCells() {
        app.segmentedControls["templatePicker"].buttons["2 × 2"].tap()
        // Wait for cells to appear
        let firstCell = app.otherElements["collageCell_0"]
        XCTAssertTrue(firstCell.waitForExistence(timeout: 2))
        XCTAssertTrue(app.otherElements["collageCell_1"].exists)
        XCTAssertTrue(app.otherElements["collageCell_2"].exists)
        XCTAssertTrue(app.otherElements["collageCell_3"].exists)
    }

    func testTemplatePicker_selectSingle_showsOneCell() {
        // Switch away then back so the picker tap registers a change
        app.segmentedControls["templatePicker"].buttons["1 × 2"].tap()
        app.segmentedControls["templatePicker"].buttons["1 × 1"].tap()
        let cell = app.otherElements["collageCell_0"]
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        XCTAssertFalse(app.otherElements["collageCell_1"].exists)
    }

    // MARK: - Create Tab: Aspect Ratio Picker

    func testAspectRatioPicker_exists() {
        XCTAssertTrue(app.segmentedControls["aspectRatioPicker"].exists)
    }

    func testAspectRatioPicker_allSegmentsPresent() {
        let picker = app.segmentedControls["aspectRatioPicker"]
        XCTAssertTrue(picker.buttons["1:1"].exists)
        XCTAssertTrue(picker.buttons["3:4"].exists)
        XCTAssertTrue(picker.buttons["4:3"].exists)
        XCTAssertTrue(picker.buttons["9:16"].exists)
    }

    // MARK: - Create Tab: Save Button State

    func testSaveButton_disabledByDefault() {
        let saveButton = app.buttons["saveButton"]
        XCTAssertTrue(saveButton.exists)
        XCTAssertFalse(saveButton.isEnabled)
    }

    // MARK: - Library Tab

    func testLibraryTab_emptyState_showsContentUnavailableView() {
        app.tabBars.buttons["Library"].tap()
        XCTAssertTrue(app.otherElements["libraryEmptyState"].waitForExistence(timeout: 2))
    }

    // MARK: - Color Hunt Tab

    func testColorHuntTab_initialState_showsEmptyStateAndHuntButton() {
        app.tabBars.buttons["Color Hunt"].tap()
        XCTAssertTrue(app.otherElements["colorHuntEmptyState"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["huntButton"].exists)
    }

    func testHuntButton_isEnabledBeforeAnalysis() {
        app.tabBars.buttons["Color Hunt"].tap()
        XCTAssertTrue(app.buttons["huntButton"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["huntButton"].isEnabled)
    }
}
