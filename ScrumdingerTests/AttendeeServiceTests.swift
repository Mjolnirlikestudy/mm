import XCTest
@testable import Scrumdinger

final class AttendeeServiceTests: XCTestCase {
    private let fixture = """
    [
      { "id": 1, "name": "Leanne Graham" },
      { "id": 2, "name": "Ervin Howell" },
      { "id": 3, "name": "Clementine Bauch" },
      { "id": 4, "name": "Patricia Lebsack" },
      { "id": 5, "name": "Chelsey Dietrich" },
      { "id": 6, "name": "Mrs. Dennis Schulist" }
    ]
    """.data(using: .utf8)!

    func testDecodeNamesRespectsLimit() throws {
        let names = try AttendeeService.decodeNames(from: fixture, limit: 3)

        XCTAssertEqual(names, ["Leanne Graham", "Ervin Howell", "Clementine Bauch"])
    }

    func testDecodeNamesReturnsAllWhenLimitExceedsCount() throws {
        let names = try AttendeeService.decodeNames(from: fixture, limit: 99)

        XCTAssertEqual(names.count, 6)
    }

    func testDecodeInvalidPayloadThrows() {
        let invalid = Data("{\"name\": \"single object\"}".utf8)

        XCTAssertThrowsError(try AttendeeService.decodeNames(from: invalid, limit: 5))
    }
}
