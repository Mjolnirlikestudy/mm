import SwiftUI

struct MeetingTimerView: View {
    let attendees: [String]
    let speakerIndex: Int
    let secondsElapsed: Int
    let secondsPerAttendee: Double
    var mainColor: Color = .accentColor
    var accentColor: Color = .secondary

    private var speaker: String {
        attendees.indices.contains(speakerIndex) ? attendees[speakerIndex] : "—"
    }

    private func fraction(for index: Int) -> Double {
        guard secondsPerAttendee > 0, !attendees.isEmpty else { return 0 }
        if index < speakerIndex { return 1 }
        if index > speakerIndex { return 0 }
        let completed = Double(index) * secondsPerAttendee
        let within = Double(secondsElapsed) - completed
        return min(max(within / secondsPerAttendee, 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(accentColor.opacity(0.25), lineWidth: 12)

            ForEach(attendees.indices, id: \.self) { index in
                SpeakerArc(speakerIndex: index,
                           totalSpeakers: attendees.count,
                           fraction: fraction(for: index))
                    .stroke(mainColor,
                            style: StrokeStyle(lineWidth: 12, lineCap: .butt))
            }

            VStack(spacing: 8) {
                Text("Current Speaker")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(speaker)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .padding()
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(24)
        .animation(.easeInOut(duration: 0.2), value: secondsElapsed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current speaker \(speaker)")
    }
}

#Preview {
    MeetingTimerView(attendees: ["Cathy", "Daisy", "Simon", "Jonathan"],
                     speakerIndex: 1,
                     secondsElapsed: 150,
                     secondsPerAttendee: 75,
                     mainColor: .teal,
                     accentColor: .teal)
}
