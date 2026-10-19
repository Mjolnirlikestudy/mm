import SwiftUI

/// 环形进度环的一段：从整圆的 `startFraction` 开始，长度占整圆的 `lengthFraction`；
/// `fillFraction` 控制这一段画到多少（0...1），用于表现当前发言人已用时间。
struct SpeakerArc: Shape {
    var startFraction: Double
    var lengthFraction: Double
    var fillFraction: Double = 1

    func path(in rect: CGRect) -> Path {
        guard lengthFraction > 0, fillFraction > 0 else { return Path() }

        let startDegrees = 360 * startFraction - 90
        let endDegrees = startDegrees + 360 * lengthFraction * min(max(fillFraction, 0), 1)

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                    radius: min(rect.width, rect.height) / 2,
                    startAngle: .degrees(startDegrees),
                    endAngle: .degrees(endDegrees),
                    clockwise: false)
        return path
    }
}

#Preview {
    ZStack {
        SpeakerArc(startFraction: 0, lengthFraction: 0.25)
            .stroke(.blue, lineWidth: 12)
        SpeakerArc(startFraction: 0.25, lengthFraction: 0.25, fillFraction: 0.4)
            .stroke(.orange, lineWidth: 12)
    }
    .padding()
}
