import Combine
import Foundation

/// 环形环上的一段，对应一位参会者的发言时段。
struct SpeakerSpan: Identifiable {
    let id: Int
    let start: Int
    let end: Int
    let isCompleted: Bool
    let isActive: Bool
}

/// 会议计时器。
///
/// 语义：总时长固定，按下「下一位」只切换发言人，**不修改已用时间**；
/// 当前发言人提前结束后，剩余时间在剩余发言人之间重新平均分配。
/// 因此顶部时钟连续前进，环在总时长走完时正好填满。
///
/// `tick()` 单独暴露，便于单元测试用确定步长驱动，而不依赖真实时钟。
final class ScrumTimer: ObservableObject {
    @Published private(set) var secondsElapsed = 0
    @Published private(set) var activeSpeakerIndex = 0
    @Published private(set) var isFinished = false

    /// 某位参会者用满时间、切换到下一位时触发（用于播放「叮」声）。
    var onSpeakerCompleted: (() -> Void)?

    let lengthInMinutes: Int
    let attendees: [String]

    /// 每位发言人开始发言的时刻（秒），按索引顺序增长。
    private var speakerStarts: [Int] = [0]
    /// 已结束发言的发言人的结束时刻，与 `speakerStarts` 中已完成的下标对应。
    private var completedEnds: [Int] = []

    private var timerCancellable: AnyCancellable?

    var totalSeconds: Int { lengthInMinutes * 60 }
    var secondsRemaining: Int { max(totalSeconds - secondsElapsed, 0) }

    var currentStart: Int {
        speakerStarts.indices.contains(activeSpeakerIndex) ? speakerStarts[activeSpeakerIndex] : 0
    }

    var remainingSpeakerCount: Int {
        max(attendees.count - activeSpeakerIndex, 0)
    }

    /// 当前发言人分到的时间（秒）。
    var currentQuota: Int {
        guard remainingSpeakerCount > 0 else { return 0 }
        return (totalSeconds - currentStart) / remainingSpeakerCount
    }

    /// 当前发言人应该结束的时刻。
    var currentDeadline: Int {
        min(totalSeconds, currentStart + currentQuota)
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

    /// 点击「下一位」：只切换发言人，已用时间保持不变。
    func nextSpeaker() {
        guard !attendees.isEmpty else { return }
        let nextIndex = activeSpeakerIndex + 1
        guard nextIndex < attendees.count else { return }
        advance(to: nextIndex, at: secondsElapsed)
    }

    /// 前进一秒。走完当前发言人的配额就切人，走完总时长则结束。
    func tick() {
        guard totalSeconds > 0, !isFinished else { return }
        secondsElapsed = min(secondsElapsed + 1, totalSeconds)

        guard secondsElapsed >= currentDeadline else { return }

        if activeSpeakerIndex >= attendees.count - 1 {
            isFinished = true
            stop()
        } else {
            advance(to: activeSpeakerIndex + 1, at: secondsElapsed)
            onSpeakerCompleted?()
        }
    }

    /// 各发言人当前的时间段，供环形进度环绘制。
    func speakerSpans() -> [SpeakerSpan] {
        guard !attendees.isEmpty, totalSeconds > 0 else { return [] }

        var spans: [SpeakerSpan] = []
        for index in 0..<activeSpeakerIndex {
            let start = speakerStarts.indices.contains(index) ? speakerStarts[index] : 0
            let end = completedEnds.indices.contains(index) ? completedEnds[index] : start
            spans.append(SpeakerSpan(id: index,
                                     start: start,
                                     end: max(start, end),
                                     isCompleted: true,
                                     isActive: false))
        }

        let activeEnd = currentDeadline
        spans.append(SpeakerSpan(id: activeSpeakerIndex,
                                 start: currentStart,
                                 end: activeEnd,
                                 isCompleted: false,
                                 isActive: true))

        let futureCount = attendees.count - activeSpeakerIndex - 1
        if futureCount > 0 {
            let remaining = max(totalSeconds - activeEnd, 0)
            let perSpeaker = remaining / futureCount
            var cursor = activeEnd
            for index in (activeSpeakerIndex + 1)..<attendees.count {
                let end = index == attendees.count - 1 ? totalSeconds : cursor + perSpeaker
                spans.append(SpeakerSpan(id: index,
                                         start: cursor,
                                         end: max(cursor, end),
                                         isCompleted: false,
                                         isActive: false))
                cursor = end
            }
        }

        return spans
    }

    private func advance(to index: Int, at time: Int) {
        if completedEnds.indices.contains(activeSpeakerIndex) {
            completedEnds[activeSpeakerIndex] = time
        } else {
            completedEnds.append(time)
        }

        activeSpeakerIndex = index
        if speakerStarts.indices.contains(index) {
            speakerStarts[index] = time
        } else {
            speakerStarts.append(time)
        }
    }
}
