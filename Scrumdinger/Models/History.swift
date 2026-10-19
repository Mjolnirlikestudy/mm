import Foundation

/// 一次已结束会议的快照，用于「历史记录」。
struct History: Identifiable, Hashable, Codable {
    let id: UUID
    let date: Date
    let attendees: [String]
    let lengthInMinutes: Int
    let transcript: String

    init(id: UUID = UUID(),
         date: Date = Date(),
         attendees: [String],
         lengthInMinutes: Int,
         transcript: String = "") {
        self.id = id
        self.date = date
        self.attendees = attendees
        self.lengthInMinutes = lengthInMinutes
        self.transcript = transcript
    }
}
