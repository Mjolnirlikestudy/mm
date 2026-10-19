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
/// 语义：总时长固定，切换发言人**不修改已用时间**；
/// 当前发言人提前结束后，剩余时间在「还没发言的人」之间重新平均分配。
/// 支持手动指定下一位发言人（顺序可以打乱），发言过的人不会被再次选中。
///
/// `tick()` 单独暴露，便于单元测试用确定步长驱动，而不依赖真实时钟。
final class ScrumTimer: ObservableObject {
    @Published private(set) var secondsElapsed = 0
    @Published private(set) var activeSpeakerIndex = 0
    @Published private(set) var isFinished = false
    /// 已经发言完毕的参会者下标，按发言顺序排列。
    @Published private(set) var completedSpeakerIndices: [Int] = []

    /// 某位参会者用满时间、自动切换到下一位时触发（用于播放「叮」声）。
    var onSpeakerCompleted: (() -> Void)?

    let lengthInMinutes: Int
    let attendees: [String]

    private struct CompletedSpeech {
        let index: Int
        let start: Int
        let end: Int
    }

    private var activeStart = 0
    private var completed: [CompletedSpeech] = []
    /// 还没轮到的人，保持原始顺序；手动指定时会把选中的人从这里移除。
    private var pending: [Int]

    private var timerCancellable: AnyCancellable?

    var totalSeconds: Int { lengthInMinutes * 60 }
    var secondsRemaining: Int { max(totalSeconds - secondsElapsed, 0) }

    var remainingSpeakerCount: Int {
        attendees.isEmpty ? 0 : pending.count + 1
    }

    /// 当前发言人分到的时间（秒）。
    var currentQuota: Int {
        guard remainingSpeakerCount > 0 else { return 0 }
        return (totalSeconds - activeStart) / remainingSpeakerCount
    }

    /// 当前发言人应该结束的时刻。
    var currentDeadline: Int {
        min(totalSeconds, activeStart + currentQuota)
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(secondsElapsed) / Double(totalSeconds)
    }

    init(lengthInMinutes: Int, attendees: [String]) {
        self.lengthInMinutes = lengthInMinutes
        self.attendees = attendees
        self.pending = attendees.count > 1 ? Array(1..<attendees.count) : []
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

    /// 选择下一位发言人（可以跨顺序指定）；已用时间保持不变。
    func selectSpeaker(_ index: Int) {
        guard !attendees.isEmpty, !isFinished else { return }
        guard index != activeSpeakerIndex, pending.contains(index) else { return }

        recordActiveSpeech(at: secondsElapsed)
        pending.removeAll { $0 == index }
        activeSpeakerIndex = index
        activeStart = secondsElapsed
    }

    /// 默认切到队列里的下一位。
    func nextSpeaker() {
        guard let next = pending.first else { return }
        selectSpeaker(next)
    }

    /// 前进一秒。走完当前发言人的配额就切人，走完总时长则结束。
    func tick() {
        guard totalSeconds > 0, !isFinished else { return }
        secondsElapsed = min(secondsElapsed + 1, totalSeconds)

        guard secondsElapsed >= currentDeadline else { return }
        completeActiveSpeaker(at: secondsElapsed)
    }

    /// 各发言人当前的时间段，供环形进度环绘制（按发言顺序排列）。
    func speakerSpans() -> [SpeakerSpan] {
        guard !attendees.isEmpty, totalSeconds > 0 else { return [] }

        var spans: [SpeakerSpan] = completed.map {
            SpeakerSpan(id: $0.index,
                        start: $0.start,
                        end: max($0.start, $0.end),
                        isCompleted: true,
                        isActive: false)
        }

        let activeEnd = currentDeadline
        spans.append(SpeakerSpan(id: activeSpeakerIndex,
                                 start: activeStart,
                                 end: activeEnd,
                                 isCompleted: false,
                                 isActive: true))

        let futureCount = pending.count
        if futureCount > 0 {
            let remaining = max(totalSeconds - activeEnd, 0)
            let perSpeaker = remaining / futureCount
            var cursor = activeEnd
            for (offset, index) in pending.enumerated() {
                let end = offset == futureCount - 1 ? totalSeconds : cursor + perSpeaker
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

    private func recordActiveSpeech(at time: Int) {
        completed.append(CompletedSpeech(index: activeSpeakerIndex,
                                         start: activeStart,
                                         end: time))
        completedSpeakerIndices.append(activeSpeakerIndex)
    }

    private func completeActiveSpeaker(at time: Int) {
        recordActiveSpeech(at: time)

        if pending.isEmpty {
            isFinished = true
            stop()
            return
        }

        activeSpeakerIndex = pending.removeFirst()
        activeStart = time
        onSpeakerCompleted?()
    }
}
