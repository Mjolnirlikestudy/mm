import SwiftUI

struct MeetingHeaderView: View {
    let secondsElapsed: Int
    let secondsRemaining: Int
    let numberOfAttendees: Int

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Meeting Time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(secondsRemaining.clockTime)
                    .font(.system(.title, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                Text("Elapsed \(secondsElapsed.clockTime)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Attendees")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(numberOfAttendees)")
                    .font(.system(.title2, design: .rounded, weight: .semibold))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Meeting time \(secondsRemaining.clockTime) remaining, \(numberOfAttendees) attendees")
        .padding(.horizontal)
    }
}

#Preview {
    MeetingHeaderView(secondsElapsed: 65, secondsRemaining: 235, numberOfAttendees: 4)
        .padding()
}
