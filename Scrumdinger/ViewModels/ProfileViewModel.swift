import Combine
import Foundation

/// 个人中心页面的 ViewModel。
final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: UserProfile

    init(profile: UserProfile = .sample) {
        self.profile = profile
    }

    var displayRole: String {
        "\(profile.department) · \(profile.role)"
    }
}
