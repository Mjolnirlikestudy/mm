import XCTest

final class ScrumdingerUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testNewScrumFlowPersistsAcrossLaunch() {
        let app = XCUIApplication()
        app.launchArguments = ["-resetData", "-AppleLanguages", "(en)"]
        app.launch()

        app.buttons["New Scrum"].tap()
        XCTAssertTrue(app.navigationBars["New Scrum"].waitForExistence(timeout: 5))

        let titleField = app.textFields["Title"]
        titleField.tap()
        titleField.typeText("Team Sync")

        let attendeesField = app.textFields["Attendees"]
        attendeesField.tap()
        attendeesField.typeText("Alice, Bob")

        app.buttons["Done"].tap()

        // 列表是懒加载的，新卡片在屏幕外，先滚动再断言
        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Team Sync"].waitForExistence(timeout: 5))

        // 重新启动后数据仍然存在，验证 JSON 持久化（第二次启动不能再带 -resetData）
        app.terminate()
        app.launchArguments = ["-AppleLanguages", "(en)"]
        app.launch()
        app.swipeUp()

        XCTAssertTrue(app.staticTexts["Team Sync"].waitForExistence(timeout: 5))
    }

    func testScreenshotTour() {
        let app = XCUIApplication()
        app.launchArguments = ["-resetData", "-AppleLanguages", "(en)"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Daily Scrums"].waitForExistence(timeout: 5))
        saveScreenshot("01-scrums-list")

        app.staticTexts["Design"].tap()
        XCTAssertTrue(app.navigationBars["Design"].waitForExistence(timeout: 5))
        saveScreenshot("02-detail")

        app.navigationBars.buttons["Edit"].tap()
        XCTAssertTrue(app.navigationBars["Design"].waitForExistence(timeout: 5))
        saveScreenshot("03-edit")
        app.buttons["Cancel"].tap()

        app.staticTexts["Start Meeting"].tap()
        XCTAssertTrue(app.staticTexts["Current Speaker"].waitForExistence(timeout: 5))
        sleep(2)
        saveScreenshot("04-meeting")

        app.buttons["Next"].tap()
        sleep(2)
        saveScreenshot("05-meeting-next-speaker")

        app.buttons["End"].tap()
        XCTAssertTrue(app.navigationBars["Design"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["No history yet"].exists)
        saveScreenshot("06-detail-history")

        app.buttons["history-row"].tap()
        XCTAssertTrue(app.navigationBars["History"].waitForExistence(timeout: 5))
        saveScreenshot("07-history")
    }

    func testChineseLocalizationScreenshot() {
        let app = XCUIApplication()
        app.launchArguments = ["-resetData", "-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        XCTAssertTrue(app.navigationBars["每日站会"].waitForExistence(timeout: 5))
        saveScreenshot("08-scrums-list-zh")

        app.staticTexts["Design"].tap()
        XCTAssertTrue(app.navigationBars["Design"].waitForExistence(timeout: 5))
        saveScreenshot("09-detail-zh")
    }

    func testDarkModeScreenshot() {
        let app = XCUIApplication()
        // 深色模式由模拟器外观控制（simctl ui booted appearance dark），这里只负责截图
        app.launchArguments = ["-resetData", "-AppleLanguages", "(en)"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Daily Scrums"].waitForExistence(timeout: 5))
        saveScreenshot("10-scrums-list-dark")

        app.staticTexts["Design"].tap()
        app.staticTexts["Start Meeting"].tap()
        XCTAssertTrue(app.staticTexts["Current Speaker"].waitForExistence(timeout: 5))
        sleep(2)
        saveScreenshot("11-meeting-dark")
    }

    /// 同时保存到测试结果（attachment）与 runner 沙盒 Documents，方便拷回仓库。
    private func saveScreenshot(_ name: String) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? screenshot.pngRepresentation.write(to: directory.appendingPathComponent("\(name).png"))
    }
}
