import Combine
import Foundation

/// 「阻塞事项」页面的 ViewModel。
final class BlockerListViewModel: ObservableObject {
    @Published private(set) var blockers: [BlockerItem]

    init(blockers: [BlockerItem] = BlockerListViewModel.sampleBlockers) {
        self.blockers = blockers
    }

    func add(title: String,
             relatedTask: String,
             groupName: String,
             owner: String,
             priority: BlockerPriority) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        blockers.insert(BlockerItem(title: trimmedTitle,
                                    relatedTask: relatedTask.trimmingCharacters(in: .whitespacesAndNewlines),
                                    groupName: groupName.trimmingCharacters(in: .whitespacesAndNewlines),
                                    owner: owner.trimmingCharacters(in: .whitespacesAndNewlines),
                                    priority: priority),
                        at: 0)
    }

    static var sampleBlockers: [BlockerItem] {
        [
            BlockerItem(title: "接口联调环境不可用",
                        relatedTask: "登录模块联调",
                        groupName: "App Dev",
                        owner: "李响",
                        priority: .urgent),
            BlockerItem(title: "设计稿缺少空状态",
                        relatedTask: "空状态设计",
                        groupName: "Design",
                        owner: "王敏",
                        priority: .normal),
            BlockerItem(title: "测试设备不足",
                        relatedTask: "真机适配",
                        groupName: "Web Dev",
                        owner: "陈晨",
                        priority: .normal)
        ]
    }
}
