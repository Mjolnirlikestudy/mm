import Foundation

extension Int {
    /// 把秒数格式化成 m:ss，用于计时器与历史记录展示。
    var clockTime: String {
        String(format: "%d:%02d", self / 60, self % 60)
    }
}
