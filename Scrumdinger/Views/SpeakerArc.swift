import SwiftUI

/// 环形进度环的一段：第 `speakerIndex` 位参会者所占的圆弧。
/// `fraction` 控制这一段画到多少（0...1），用于表现当前发言人已用时间。
struct SpeakerArc: Shape {
    let speakerIndex: Int
    let totalSpeakers: Int
    var fraction: Double = 1

    func path(in rect: CGRect) -> Path {
        guard totalSpeakers > 0, fraction > 0 else { return Path() }

        let degreesPerSpeaker = 360.0 / Double(totalSpeakers)
        let startDegrees = Double(speakerIndex) * degreesPerSpeaker - 90
        let endDegrees = startDegrees + degreesPerSpeaker * min(max(fraction, 0), 1)

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
        SpeakerArc(speakerIndex: 0, totalSpeakers: 4)
            .stroke(.blue, lineWidth: 12)
        SpeakerArc(speakerIndex: 1, totalSpeakers: 4, fraction: 0.4)
            .stroke(.orange, lineWidth: 12)
    }
    .padding()
}
