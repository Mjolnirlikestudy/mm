import Combine
import Foundation

/// 「日程会议」页面的 ViewModel。
final class ScheduleViewModel: ObservableObject {
    @Published private(set) var meetings: [MeetingEvent]

    init(meetings: [MeetingEvent] = ScheduleViewModel.sampleMeetings) {
        self.meetings = meetings
    }

    func join(_ meeting: MeetingEvent) {
        guard let index = meetings.firstIndex(where: { $0.id == meeting.id }) else { return }
        meetings[index].isJoined = true
    }

    var todayMeetings: [MeetingEvent] {
        meetings
    }

    static var sampleMeetings: [MeetingEvent] {
        let calendar = Calendar.current
        let today = Date()
        func time(_ hour: Int, _ minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: today) ?? today
        }
        return [
            MeetingEvent(title: "每日站会 · 设计组", groupName: "Design", startTime: time(9, 30)),
            MeetingEvent(title: "需求评审", groupName: "Product", startTime: time(11, 0)),
            MeetingEvent(title: "迭代回顾", groupName: "App Dev", startTime: time(16, 30))
        ]
    }
}
