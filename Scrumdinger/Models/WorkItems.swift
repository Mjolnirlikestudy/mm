import SwiftUI

enum TaskStatus: String, CaseIterable, Identifiable {
    case todo
    case inProgress
    case completed

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .todo: return "To Do"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    var tint: Color {
        switch self {
        case .todo: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}

/// 「我的任务」页面使用的任务模型。
struct TaskItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var groupName: String
    var status: TaskStatus
    var dueDate: Date

    init(id: UUID = UUID(),
         title: String,
         groupName: String,
         status: TaskStatus,
         dueDate: Date) {
        self.id = id
        self.title = title
        self.groupName = groupName
        self.status = status
        self.dueDate = dueDate
    }
}

/// 「日程会议」页面使用的会议模型。
struct MeetingEvent: Identifiable, Hashable {
    let id: UUID
    var title: String
    var groupName: String
    var startTime: Date
    var isJoined: Bool

    init(id: UUID = UUID(),
         title: String,
         groupName: String,
         startTime: Date,
         isJoined: Bool = false) {
        self.id = id
        self.title = title
        self.groupName = groupName
        self.startTime = startTime
        self.isJoined = isJoined
    }
}

enum BlockerPriority: String, CaseIterable, Identifiable {
    case urgent
    case normal

    var id: String { rawValue }

    var title: LocalizedStringKey {
        switch self {
        case .urgent: return "Urgent"
        case .normal: return "Normal"
        }
    }

    var tint: Color {
        switch self {
        case .urgent: return .red
        case .normal: return .yellow
        }
    }
}

/// 「阻塞事项」页面使用的卡点模型。
struct BlockerItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var relatedTask: String
    var groupName: String
    var owner: String
    var priority: BlockerPriority

    init(id: UUID = UUID(),
         title: String,
         relatedTask: String,
         groupName: String,
         owner: String,
         priority: BlockerPriority) {
        self.id = id
        self.title = title
        self.relatedTask = relatedTask
        self.groupName = groupName
        self.owner = owner
        self.priority = priority
    }
}

/// 「站会纪要」页面使用的历史记录模型。
struct RetroNote: Identifiable, Hashable {
    let id: UUID
    var groupName: String
    var date: Date
    var summary: String

    init(id: UUID = UUID(), groupName: String, date: Date, summary: String) {
        self.id = id
        self.groupName = groupName
        self.date = date
        self.summary = summary
    }
}
