import XCTest
@testable import Scrumdinger

@MainActor
final class ScrumStoreTests: XCTestCase {
    private var fileURL: URL!

    override func setUpWithError() throws {
        fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("scrumstore-\(UUID().uuidString).json")
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: fileURL)
    }

    func testFirstLaunchSeedsSampleDataAndWritesFile() throws {
        let store = ScrumStore(fileURL: fileURL)

        XCTAssertEqual(store.scrums.count, DailyScrum.sampleData.count)
        XCTAssertNil(store.error)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
    }

    func testSaveThenReloadKeepsData() throws {
        let store = ScrumStore(fileURL: fileURL)
        store.scrums.append(DailyScrum(title: "QA",
                                       attendees: ["A", "B"],
                                       lengthInMinutes: 15,
                                       theme: .purple))
        try store.save()

        let reloaded = ScrumStore(fileURL: fileURL)

        XCTAssertEqual(reloaded.scrums.count, DailyScrum.sampleData.count + 1)
        XCTAssertEqual(reloaded.scrums.last?.title, "QA")
        XCTAssertNil(reloaded.error)
    }

    func testCorruptedFileReportsErrorAndFallsBack() throws {
        try Data("this is not json".utf8).write(to: fileURL)

        let store = ScrumStore(fileURL: fileURL)

        XCTAssertNotNil(store.error)
        XCTAssertEqual(store.scrums.count, DailyScrum.sampleData.count)
    }

    func testSaveCreatesMissingDirectory() throws {
        let nestedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("scrumstore-\(UUID().uuidString)", isDirectory: true)
            .appendingPathComponent("nested")
            .appendingPathComponent("scrums.json")
        defer { try? FileManager.default.removeItem(at: nestedURL.deletingLastPathComponent().deletingLastPathComponent()) }

        let store = ScrumStore(fileURL: nestedURL)
        try store.save()

        XCTAssertTrue(FileManager.default.fileExists(atPath: nestedURL.path))
    }
}
