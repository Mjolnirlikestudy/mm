import Foundation

/// 一次已结束会议的快照，用于「历史记录」。
struct History: Identifiable, Hashable, Codable {
    let id: UUID
    let date: Date
    let attendees: [String]
    let lengthInMinutes: Int
    let transcript: String
    /// 录音文件名（相对 Recordings 目录），没有录音时为 nil。
    var recordingFileName: String?

    init(id: UUID = UUID(),
         date: Date = Date(),
         attendees: [String],
         lengthInMinutes: Int,
         transcript: String = "",
         recordingFileName: String? = nil) {
        self.id = id
        self.date = date
        self.attendees = attendees
        self.lengthInMinutes = lengthInMinutes
        self.transcript = transcript
        self.recordingFileName = recordingFileName
    }
}
