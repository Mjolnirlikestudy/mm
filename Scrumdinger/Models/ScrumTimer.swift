import Combine
import Foundation

/// 会议计时器：把「总时长 + 参会者」换算成秒数推进、当前发言人索引与结束状态。
/// `tick()` 单独暴露，便于单元测试用确定步长驱动，而不依赖真实时钟。
final class ScrumTimer: ObservableObject {
    @Published private(set) var secondsElapsed = 0
    @Published private(set) var activeSpeakerIndex = 0
    @Published private(set) var isFinished = false

    let lengthInMinutes: Int
    let attendees: [String]

    /// 某位参会者用满时间、切换到下一位时触发（用于播放「叮」声）。
    var onSpeakerCompleted: (() -> Void)?

    private var timerCancellable: AnyCancellable?

    var totalSeconds: Int { lengthInMinutes * 60 }
    var secondsRemaining: Int { max(totalSeconds - secondsElapsed, 0) }

    /// 每位参会者分到的秒数，用于环形进度分段与切人判断。
    var secondsPerAttendee: Double {
        guard !attendees.isEmpty else { return 0 }
        return Double(totalSeconds) / Double(attendees.count)
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(secondsElapsed) / Double(totalSeconds)
    }

    init(lengthInMinutes: Int, attendees: [String]) {
        self.lengthInMinutes = lengthInMinutes
        self.attendees = attendees
    }

    func start() {
        guard timerCancellable == nil, !isFinished else { return }
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func stop() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    /// 点击「下一位」：直接把时间跳到下一位发言者的起点。
    func nextSpeaker() {
        guard !attendees.isEmpty else { return }
        let nextIndex = activeSpeakerIndex + 1
        guard nextIndex < attendees.count else { return }
        activeSpeakerIndex = nextIndex
        secondsElapsed = min(totalSeconds, Int((Double(nextIndex) * secondsPerAttendee).rounded()))
    }

    /// 前进一秒。到达总时长后置 `isFinished` 并停止计时。
    func tick() {
        guard totalSeconds > 0, !isFinished else { return }
        secondsElapsed = min(secondsElapsed + 1, totalSeconds)
        let previousSpeaker = activeSpeakerIndex
        activeSpeakerIndex = speakerIndex(for: secondsElapsed)
        if activeSpeakerIndex != previousSpeaker {
            onSpeakerCompleted?()
        }
        if secondsElapsed >= totalSeconds {
            isFinished = true
            stop()
        }
    }

    /// 某一名已用秒数对应第几位发言者（0 起）。
    func speakerIndex(for elapsed: Int) -> Int {
        guard !attendees.isEmpty, secondsPerAttendee > 0 else { return 0 }
        let rawIndex = Int(Double(elapsed) / secondsPerAttendee)
        return min(rawIndex, attendees.count - 1)
    }
}
