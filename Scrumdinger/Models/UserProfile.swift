import Foundation

/// 个人中心展示的用户信息。
struct UserProfile {
    let name: String
    let department: String
    let role: String
    let avatarSystemName: String

    static let sample = UserProfile(name: "萌萌",
                                    department: "产品设计部",
                                    role: "敏捷教练",
                                    avatarSystemName: "person.crop.circle.fill")
}
