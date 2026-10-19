import XCTest
@testable import Scrumdinger

final class ScrumTimerTests: XCTestCase {
    func testInitialSpansSplitTotalEqually() {
        // 10 分钟 4 人 → 每人 150 秒
        let timer = ScrumTimer(lengthInMinutes: 10, attendees: ["A", "B", "C", "D"])
        let spans = timer.speakerSpans()

        XCTAssertEqual(spans.count, 4)
        XCTAssertEqual(spans.map(\.start), [0, 150, 300, 450])
        XCTAssertEqual(spans.map(\.end), [150, 300, 450, 600])
        XCTAssertEqual(spans.first?.isActive, true)
        XCTAssertEqual(timer.currentQuota, 150)
        XCTAssertEqual(timer.totalSeconds, 600)
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

    func testNextSpeakerDoesNotJumpElapsedTime() {
        let timer = ScrumTimer(lengthInMinutes: 10, attendees: ["A", "B", "C", "D"])
        for _ in 0..<3 {
            timer.tick()
        }

        timer.nextSpeaker()

        // 关键：切换发言人后已用时间仍然是 3 秒，时钟不跳
        XCTAssertEqual(timer.secondsElapsed, 3)
        XCTAssertEqual(timer.activeSpeakerIndex, 1)

        // 第一位被提前结束，只占用 0–3 秒
        let spans = timer.speakerSpans()
        XCTAssertEqual(spans[0].start, 0)
        XCTAssertEqual(spans[0].end, 3)
        XCTAssertTrue(spans[0].isCompleted)
        XCTAssertEqual(spans[1].start, 3)
        XCTAssertTrue(spans[1].isActive)

        // 剩余 597 秒由 3 人平分，每人 199 秒
        XCTAssertEqual(timer.currentQuota, 199)
        XCTAssertEqual(spans[1].end, 202)
        XCTAssertEqual(spans.last?.end, 600)
    }

    func testNextSpeakerAtLastSpeakerIsNoOp() {
        let timer = ScrumTimer(lengthInMinutes: 10, attendees: ["A", "B", "C", "D"])

        timer.nextSpeaker()
        timer.nextSpeaker()
        timer.nextSpeaker()
        XCTAssertEqual(timer.activeSpeakerIndex, 3)

        timer.nextSpeaker()
        XCTAssertEqual(timer.activeSpeakerIndex, 3)
        XCTAssertEqual(timer.secondsElapsed, 0)
    }

    func testEmptyAttendeesDoesNotCrash() {
        let timer = ScrumTimer(lengthInMinutes: 5, attendees: [])
        timer.tick()
        timer.nextSpeaker()

        XCTAssertTrue(timer.speakerSpans().isEmpty)
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

    func testSkippingRedistributesRemainingTime() {
        let timer = ScrumTimer(lengthInMinutes: 10, attendees: ["A", "B", "C", "D"])

        // 第一位只用了 10 秒就跳过，剩余 590 秒由 3 人平分（196 / 197 秒）
        for _ in 0..<10 {
            timer.tick()
        }
        timer.nextSpeaker()

        XCTAssertEqual(timer.secondsElapsed, 10)
        XCTAssertEqual(timer.currentQuota, 196)
        XCTAssertEqual(timer.speakerSpans().reduce(0) { $0 + ($1.end - $1.start) }, 600)
    }
}
