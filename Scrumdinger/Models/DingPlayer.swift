import AVFoundation
import AudioToolbox

/// 播放「叮」声：优先播放随包的 ding.wav，缺失时退回系统音效。
final class DingPlayer {
    static let shared = DingPlayer()

    private var player: AVAudioPlayer?

    func play() {
        if let url = Bundle.main.url(forResource: "ding", withExtension: "wav"),
           let player = try? AVAudioPlayer(contentsOf: url) {
            self.player = player
            player.play()
        } else {
            AudioServicesPlaySystemSound(1057)
        }
    }
}
