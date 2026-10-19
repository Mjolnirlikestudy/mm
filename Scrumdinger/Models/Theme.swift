import SwiftUI

/// 一个可 Codable 的颜色值，让 Theme 能直接持久化到 JSON。
struct ColorValue: Hashable, Codable {
    var red: Double
    var green: Double
    var blue: Double

    static func rgb(_ red: Double, _ green: Double, _ blue: Double) -> ColorValue {
        ColorValue(red: red, green: green, blue: blue)
    }

    var color: Color {
        Color(red: red, green: green, blue: blue)
    }
}

/// 站会配色主题。
struct Theme: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var mainColor: ColorValue
    var accentColor: ColorValue

    init(id: UUID = UUID(), name: String, mainColor: ColorValue, accentColor: ColorValue) {
        self.id = id
        self.name = name
        self.mainColor = mainColor
        self.accentColor = accentColor
    }

    var main: Color { mainColor.color }
    var accent: Color { accentColor.color }
}

extension Theme {
    static let indigo = Theme(name: "Indigo",
                              mainColor: .rgb(0.25, 0.31, 0.62),
                              accentColor: .rgb(0.91, 0.93, 1.0))

    static let teal = Theme(name: "Teal",
                            mainColor: .rgb(0.0, 0.47, 0.47),
                            accentColor: .rgb(0.9, 1.0, 0.99))

    static let yellow = Theme(name: "Yellow",
                              mainColor: .rgb(0.85, 0.66, 0.08),
                              accentColor: .rgb(1.0, 0.98, 0.87))

    static let orange = Theme(name: "Orange",
                              mainColor: .rgb(0.8, 0.4, 0.08),
                              accentColor: .rgb(1.0, 0.94, 0.88))

    static let purple = Theme(name: "Purple",
                              mainColor: .rgb(0.44, 0.22, 0.66),
                              accentColor: .rgb(0.96, 0.92, 1.0))

    static let pink = Theme(name: "Pink",
                            mainColor: .rgb(0.78, 0.26, 0.47),
                            accentColor: .rgb(1.0, 0.92, 0.95))

    static let green = Theme(name: "Green",
                             mainColor: .rgb(0.16, 0.5, 0.29),
                             accentColor: .rgb(0.92, 1.0, 0.94))

    /// 主题选择器展示的顺序。
    static let allCases: [Theme] = [.indigo, .teal, .yellow, .orange, .purple, .pink, .green]
}
