import Combine
import Foundation

/// 站会数据的 JSON 持久化 + 错误兜底。
///
/// 设计要点：
/// - 数据文件放在 Application Support/Scrumdinger/scrums.json，首次启动时写入示例数据；
/// - 数组变化后延迟 0.4 秒合并写入，避免拖拽/编辑时频繁落盘；
/// - 读写失败统一包装成 `ErrorWrapper`，由 `ScrumsView` 弹出 `ErrorView`。
@MainActor
final class ScrumStore: ObservableObject {
    @Published var scrums: [DailyScrum] = [] {
        didSet {
            scheduleSave()
        }
    }

    @Published var error: ErrorWrapper?

    private let fileURL: URL
    private var saveTask: Task<Void, Never>?

    init(fileURL: URL? = nil) {
        let resolvedURL = fileURL ?? Self.defaultFileURL
        #if DEBUG
        // UI 测试用：启动时清空本地数据，保证截图与用例可重复。
        if ProcessInfo.processInfo.arguments.contains("-resetData") {
            try? FileManager.default.removeItem(at: resolvedURL)
        }
        #endif
        self.fileURL = resolvedURL
        load()
    }

    static var defaultFileURL: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory,
                                               in: .userDomainMask)[0]
        return support
            .appendingPathComponent("Scrumdinger", isDirectory: true)
            .appendingPathComponent("scrums.json")
    }

    var filePath: String { fileURL.path }

    func load() {
        do {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                scrums = DailyScrum.sampleData
                try save()
                return
            }
            let data = try Data(contentsOf: fileURL)
            scrums = try JSONDecoder.scrumdinger.decode([DailyScrum].self, from: data)
        } catch {
            self.error = ErrorWrapper(error: error,
                                 guidance: "读取站会数据失败。已保留原始文件，请检查存储空间后重试。")
            scrums = DailyScrum.sampleData
        }
    }

    func save() throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let data = try JSONEncoder.scrumdinger.encode(scrums)
        try data.write(to: fileURL, options: .atomic)
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled, let self else { return }
            do {
                try self.save()
            } catch {
                self.error = ErrorWrapper(error: error,
                                          guidance: "保存站会数据失败，本次修改可能未写入磁盘。")
            }
        }
    }
}

extension JSONEncoder {
    static var scrumdinger: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

extension JSONDecoder {
    static var scrumdinger: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
