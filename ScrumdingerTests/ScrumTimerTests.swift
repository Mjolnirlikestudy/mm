import XCTest
@testable import Scrumdinger

final class ScrumTimerTests: XCTestCase {
    func testSpeakerIndexMapping() {
        // 10 分钟 4 人 → 每人 150 秒
        let timer = ScrumTimer(lengthInMinutes: 10, attendees: ["A", "B", "C", "D"])

        XCTAssertEqual(timer.speakerIndex(for: 0), 0)
        XCTAssertEqual(timer.speakerIndex(for: 149), 0)
        XCTAssertEqual(timer.speakerIndex(for: 150), 1)
        XCTAssertEqual(timer.speakerIndex(for: 451), 3)
        XCTAssertEqual(timer.speakerIndex(for: 600), 3)
    }

    func testSecondsPerAttendeeUsesTotalLength() {
        let timer = ScrumTimer(lengthInMinutes: 10, attendees: ["A", "B", "C", "D"])
        XCTAssertEqual(timer.secondsPerAttendee, 150, accuracy: 0.001)
        XCTAssertEqual(timer.secondsRemaining, 600)
    }

    func testTickAdvancesSpeakerAndTriggersDing() {
        // 1 分钟 2 人 → 每人 30 秒
        let timer = ScrumTimer(lengthInMinutes: 1, attendees: ["A", "B"])
        var dingCount = 0
        timer.onSpeakerCompleted = { dingCount += 1 }

        for _ in 0..<30 {
            timer.tick()
        }

        XCTAssertEqual(timer.secondsElapsed, 30)
        XCTAssertEqual(timer.activeSpeakerIndex, 1)
        XCTAssertEqual(dingCount, 1)
    }

    func testTimerFinishesExactlyAtTotalLength() {
        let timer = ScrumTimer(lengthInMinutes: 1, attendees: ["A", "B"])
        for _ in 0..<60 {
            timer.tick()
        }

        XCTAssertTrue(timer.isFinished)
        XCTAssertEqual(timer.secondsRemaining, 0)

        // 结束后再 tick 不应该越界
        timer.tick()
        XCTAssertEqual(timer.secondsElapsed, 60)
    }

    func testNextSpeakerJumpsToSpeakerBoundary() {
        let timer = ScrumTimer(lengthInMinutes: 10, attendees: ["A", "B", "C", "D"])
        timer.nextSpeaker()

        XCTAssertEqual(timer.activeSpeakerIndex, 1)
        XCTAssertEqual(timer.secondsElapsed, 150)

        // 最后一位再点「下一位」保持不动
        timer.nextSpeaker()
        timer.nextSpeaker()
        timer.nextSpeaker()
        XCTAssertEqual(timer.activeSpeakerIndex, 3)
    }

    func testEmptyAttendeesDoesNotCrash() {
        let timer = ScrumTimer(lengthInMinutes: 5, attendees: [])
        timer.tick()
        timer.nextSpeaker()

        XCTAssertEqual(timer.secondsPerAttendee, 0)
        XCTAssertEqual(timer.activeSpeakerIndex, 0)
        XCTAssertEqual(timer.secondsElapsed, 1)
    }

    func testProgressTracksElapsed() {
        let timer = ScrumTimer(lengthInMinutes: 1, attendees: ["A", "B"])
        for _ in 0..<15 {
            timer.tick()
        }
        XCTAssertEqual(timer.progress, 0.25, accuracy: 0.001)
    }
}
