import Foundation

/// 一场每日站会的定义。
struct DailyScrum: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var attendees: [String]
    var lengthInMinutes: Int
    var theme: Theme
    var history: [History]

    init(id: UUID = UUID(),
         title: String,
         attendees: [String],
         lengthInMinutes: Int,
         theme: Theme,
         history: [History] = []) {
        self.id = id
        self.title = title
        self.attendees = attendees
        self.lengthInMinutes = lengthInMinutes
        self.theme = theme
        self.history = history
    }
}

extension DailyScrum {
    static var sampleData: [DailyScrum] {
        [
            DailyScrum(title: "Design",
                       attendees: ["Cathy", "Daisy", "Simon", "Jonathan"],
                       lengthInMinutes: 10,
                       theme: .yellow),
            DailyScrum(title: "App Dev",
                       attendees: ["Katie", "Gray", "Euna", "Luis", "Darla"],
                       lengthInMinutes: 5,
                       theme: .orange),
            DailyScrum(title: "Web Dev",
                       attendees: ["Chella", "Chris", "Christina", "Eden", "Karla", "Lindsey", "Aga", "Chad", "Jenn", "Sarah"],
                       lengthInMinutes: 5,
                       theme: .green)
        ]
    }
}
