import Foundation

/// 把任意 Error 包成 Identifiable，方便用 `.sheet(item:)` / `.alert(item:)` 展示。
struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: Error
    /// 给用户的操作建议，比如「检查文件权限后重试」。
    let guidance: String
}
