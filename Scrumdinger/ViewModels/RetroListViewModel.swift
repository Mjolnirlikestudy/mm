import Combine
import Foundation

/// 「站会纪要」页面的 ViewModel。
final class RetroListViewModel: ObservableObject {
    @Published private(set) var notes: [RetroNote]

    init(notes: [RetroNote] = RetroListViewModel.sampleNotes) {
        self.notes = notes
    }

    static var sampleNotes: [RetroNote] {
        let now = Date()
        let calendar = Calendar.current
        func day(_ offset: Int) -> Date {
            calendar.date(byAdding: .day, value: offset, to: now) ?? now
        }
        return [
            RetroNote(groupName: "Design",
                      date: day(0),
                      summary: "确认首页卡片圆角统一为 14，补充空状态文案，明天评审改版稿。"),
            RetroNote(groupName: "App Dev",
                      date: day(-1),
                      summary: "计时器改为连续时钟，下一位可手动指定；联调环境问题由李响跟进。"),
            RetroNote(groupName: "Web Dev",
                      date: day(-2),
                      summary: "补全进度环异常分支，完成真机回归，剩余 2 个阻塞项。")
        ]
    }
}
