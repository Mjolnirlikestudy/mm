import XCTest
@testable import Scrumdinger

final class ModelTests: XCTestCase {
    func testDailyScrumCodableRoundTrip() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let scrum = DailyScrum(
            title: "Design",
            attendees: ["Cathy", "Daisy"],
            lengthInMinutes: 10,
            theme: .teal,
            history: [
                History(date: date,
                        attendees: ["Cathy"],
                        lengthInMinutes: 10,
                        transcript: "Design review",
                        recordingFileName: "sample.m4a")
            ]
        )

        let data = try JSONEncoder.scrumdinger.encode([scrum])
        let decoded = try JSONDecoder.scrumdinger.decode([DailyScrum].self, from: data)

        XCTAssertEqual(decoded, [scrum])
        XCTAssertEqual(decoded[0].history.first?.recordingFileName, "sample.m4a")
    }

    func testHistoryWithoutRecordingDecodes() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let history = History(date: date,
                              attendees: ["A"],
                              lengthInMinutes: 5,
                              transcript: "")

        let data = try JSONEncoder.scrumdinger.encode(history)
        let decoded = try JSONDecoder.scrumdinger.decode(History.self, from: data)

        XCTAssertNil(decoded.recordingFileName)
        XCTAssertEqual(decoded, history)
    }

    func testClockTimeFormatting() {
        XCTAssertEqual(0.clockTime, "0:00")
        XCTAssertEqual(59.clockTime, "0:59")
        XCTAssertEqual(65.clockTime, "1:05")
        XCTAssertEqual(600.clockTime, "10:00")
    }

    func testThemePresetsAreStable() {
        XCTAssertEqual(Theme.allCases.count, 7)
        XCTAssertEqual(Theme.allCases.map(\.name), [
            "Indigo", "Teal", "Yellow", "Orange", "Purple", "Pink", "Green"
        ])
        XCTAssertEqual(Theme.teal.name, "Teal")
    }

    func testThemeColorRoundTrip() throws {
        let data = try JSONEncoder().encode(Theme.orange)
        let decoded = try JSONDecoder().decode(Theme.self, from: data)

        XCTAssertEqual(decoded.name, Theme.orange.name)
        XCTAssertEqual(decoded.mainColor, Theme.orange.mainColor)
        XCTAssertEqual(decoded.accentColor, Theme.orange.accentColor)
    }
}
