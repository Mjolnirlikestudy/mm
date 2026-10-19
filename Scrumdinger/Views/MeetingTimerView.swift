import SwiftUI

struct MeetingTimerView: View {
    let attendees: [String]
    let speakerIndex: Int

    private var speaker: String {
        attendees.indices.contains(speakerIndex) ? attendees[speakerIndex] : "—"
    }

    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(.quaternary, lineWidth: 10)

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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Current speaker \(speaker)")
    }
}

#Preview {
    MeetingTimerView(attendees: ["Cathy", "Daisy", "Simon", "Jonathan"], speakerIndex: 1)
}
