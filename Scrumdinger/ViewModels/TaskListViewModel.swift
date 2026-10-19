import Combine
import Foundation

/// 「我的任务」页面的 ViewModel。
final class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem]

    private let calendar = Calendar.current

    init(tasks: [TaskItem] = TaskListViewModel.sampleTasks) {
        self.tasks = tasks
    }

    func add(title: String, groupName: String, status: TaskStatus, dueDate: Date) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let trimmedGroup = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        tasks.insert(TaskItem(title: trimmedTitle,
                              groupName: trimmedGroup.isEmpty ? "Design" : trimmedGroup,
                              status: status,
                              dueDate: dueDate),
                     at: 0)
    }

    func delete(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
    }

    static var sampleTasks: [TaskItem] {
        let now = Date()
        return [
            TaskItem(title: "完成站会卡片圆角规范",
                     groupName: "Design",
                     status: .inProgress,
                     dueDate: Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now),
            TaskItem(title: "重构计时器状态管理",
                     groupName: "App Dev",
                     status: .todo,
                     dueDate: Calendar.current.date(byAdding: .day, value: 3, to: now) ?? now),
            TaskItem(title: "整理本周站会纪要",
                     groupName: "Design",
                     status: .completed,
                     dueDate: Calendar.current.date(byAdding: .day, value: -1, to: now) ?? now),
            TaskItem(title: "修复环形进度环显示问题",
                     groupName: "Web Dev",
                     status: .inProgress,
                     dueDate: Calendar.current.date(byAdding: .day, value: 5, to: now) ?? now)
        ]
    }
}
