import SwiftUI

struct MeetingTimerView: View {
    let attendees: [String]
    let speakerIndex: Int
    let secondsElapsed: Int
    let spans: [SpeakerSpan]
    let totalSeconds: Int
    var mainColor: Color = .accentColor
    var accentColor: Color = .secondary

    private var speaker: String {
        attendees.indices.contains(speakerIndex) ? attendees[speakerIndex] : "—"
    }

    private func fraction(_ seconds: Int) -> Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(max(seconds, 0)) / Double(totalSeconds)
    }

    private func fill(for span: SpeakerSpan) -> Double {
        if span.isCompleted { return 1 }
        guard span.isActive else { return 0 }
        let duration = max(span.end - span.start, 1)
        return min(max(Double(secondsElapsed - span.start) / Double(duration), 0), 1)
    }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(accentColor.opacity(0.25), lineWidth: 12)

            ForEach(spans) { span in
                SpeakerArc(startFraction: fraction(span.start),
                           lengthFraction: fraction(span.end - span.start),
                           fillFraction: fill(for: span))
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
        .animation(.linear(duration: 0.2), value: secondsElapsed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current speaker \(speaker)")
    }
}

#Preview {
    MeetingTimerView(attendees: ["Cathy", "Daisy", "Simon", "Jonathan"],
                     speakerIndex: 1,
                     secondsElapsed: 170,
                     spans: [
                        SpeakerSpan(id: 0, start: 0, end: 150, isCompleted: true, isActive: false),
                        SpeakerSpan(id: 1, start: 150, end: 300, isCompleted: false, isActive: true),
                        SpeakerSpan(id: 2, start: 300, end: 450, isCompleted: false, isActive: false),
                        SpeakerSpan(id: 3, start: 450, end: 600, isCompleted: false, isActive: false)
                     ],
                     totalSeconds: 600,
                     mainColor: .teal,
                     accentColor: .teal)
}
