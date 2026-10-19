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

        app.swipeUp()
        XCTAssertTrue(app.staticTexts["Team Sync"].waitForExistence(timeout: 5))

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
        saveScreenshot("01-daily-scrums")

        // 点击卡片直接开始计时
        app.staticTexts["Design"].tap()
        XCTAssertTrue(app.staticTexts["Current Speaker"].waitForExistence(timeout: 5))
        sleep(2)
        saveScreenshot("02-meeting")

        // 下一位：弹出选择发言人的面板
        app.buttons["Next"].tap()
        XCTAssertTrue(app.navigationBars["Next Speaker"].waitForExistence(timeout: 5))
        saveScreenshot("03-speaker-picker")

        app.staticTexts["Daisy"].tap()
        XCTAssertTrue(app.staticTexts["Daisy"].waitForExistence(timeout: 5))
        sleep(1)
        saveScreenshot("04-meeting-next")

        app.buttons["End"].tap()
        XCTAssertTrue(app.navigationBars["Daily Scrums"].waitForExistence(timeout: 5))

        // 我的
        app.tabBars.buttons["Me"].tap()
        XCTAssertTrue(app.navigationBars["Me"].waitForExistence(timeout: 5))
        saveScreenshot("05-profile")

        openQuickAction(app, title: "My Tasks")
        saveScreenshot("06-tasks")

        app.buttons["New Task"].tap()
        XCTAssertTrue(app.navigationBars["New Task"].waitForExistence(timeout: 5))
        saveScreenshot("07-new-task")
        app.buttons["Cancel"].tap()

        goBack(app)
        openQuickAction(app, title: "Schedule")
        saveScreenshot("08-schedule")

        goBack(app)
        openQuickAction(app, title: "Blockers")
        saveScreenshot("09-blockers")

        goBack(app)
        openQuickAction(app, title: "Meeting Notes")
        saveScreenshot("10-meeting-notes")
    }

    func testChineseLocalizationScreenshot() {
        let app = XCUIApplication()
        app.launchArguments = ["-resetData", "-AppleLanguages", "(zh-Hans)", "-AppleLocale", "zh_CN"]
        app.launch()

        XCTAssertTrue(app.navigationBars["每日站会"].waitForExistence(timeout: 5))
        saveScreenshot("11-daily-scrums-zh")

        app.tabBars.buttons["我的"].tap()
        XCTAssertTrue(app.navigationBars["我的"].waitForExistence(timeout: 5))
        saveScreenshot("12-profile-zh")
    }

    func testDarkModeScreenshot() {
        // 深色模式由模拟器外观控制（simctl ui booted appearance dark），这里只负责截图
        let app = XCUIApplication()
        app.launchArguments = ["-resetData", "-AppleLanguages", "(en)"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Daily Scrums"].waitForExistence(timeout: 5))
        saveScreenshot("13-daily-scrums-dark")

        app.tabBars.buttons["Me"].tap()
        XCTAssertTrue(app.navigationBars["Me"].waitForExistence(timeout: 5))
        saveScreenshot("14-profile-dark")
    }

    private func openQuickAction(_ app: XCUIApplication, title: String) {
        let element = app.staticTexts[title]
        XCTAssertTrue(element.waitForExistence(timeout: 5), "Missing quick action \(title)")
        element.tap()
        XCTAssertTrue(app.navigationBars[title].waitForExistence(timeout: 5))
    }

    private func goBack(_ app: XCUIApplication) {
        app.navigationBars.buttons.element(boundBy: 0).tap()
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
