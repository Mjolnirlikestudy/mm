import AVFoundation
import Combine
import Foundation

/// 会议录音：AVAudioRecorder 写入 Application Support/Scrumdinger/Recordings。
/// 只在用户主动点击麦克风按钮时录音，结束时把文件名写进历史记录。
@MainActor
final class AudioRecorder: ObservableObject {
    struct Alert: Identifiable {
        let id = UUID()
        let message: String
    }

    @Published private(set) var isRecording = false
    /// 最近一次录音的文件名，交给 History 保存。
    @Published private(set) var lastRecordingFileName: String?
    @Published var alert: Alert?

    private var recorder: AVAudioRecorder?

    func toggle() {
        if isRecording {
            stop()
        } else {
            requestPermissionAndStart()
        }
    }

    func requestPermissionAndStart() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            Task { @MainActor in
                guard let self else { return }
                if granted {
                    self.start()
                } else {
                    self.alert = Alert(message: "无法访问麦克风，请在系统设置中允许 Scrumdinger 使用麦克风。")
                }
            }
        }
    }

    func start() {
        guard !isRecording else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord,
                                    mode: .default,
                                    options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)

            try FileManager.default.createDirectory(at: RecordingStorage.directory,
                                                    withIntermediateDirectories: true)
            let fileName = "\(UUID().uuidString).m4a"
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            let recorder = try AVAudioRecorder(url: RecordingStorage.url(for: fileName),
                                               settings: settings)
            recorder.record()
            self.recorder = recorder
            lastRecordingFileName = fileName
            isRecording = true
        } catch {
            alert = Alert(message: "录音启动失败：\(error.localizedDescription)")
        }
    }

    func stop() {
        guard isRecording else { return }
        recorder?.stop()
        recorder = nil
        isRecording = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
