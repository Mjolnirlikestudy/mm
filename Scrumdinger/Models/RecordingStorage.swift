import AVFoundation
import Foundation

/// 录音文件存放位置。
enum RecordingStorage {
    static var directory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Scrumdinger", isDirectory: true)
            .appendingPathComponent("Recordings", isDirectory: true)
    }

    static func url(for fileName: String) -> URL {
        directory.appendingPathComponent(fileName)
    }
}
