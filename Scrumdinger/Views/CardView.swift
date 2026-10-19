import SwiftUI

struct CardView: View {
    let scrum: DailyScrum

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(scrum.theme.main)
                .frame(width: 6, height: 44)

            VStack(alignment: .leading, spacing: 6) {
                Text(scrum.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 14) {
                    Label("\(scrum.attendees.count) members", systemImage: "person.3.fill")
                    Label("\(scrum.lengthInMinutes) min", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Image(systemName: "timer")
                .font(.title3)
                .foregroundStyle(scrum.theme.main)
        }
        .cardBackground()
        .accessibilityElement(children: .combine)
        .accessibilityHint("Starts the meeting timer")
    }
}

#Preview {
    VStack {
        ForEach(DailyScrum.sampleData) { scrum in
            CardView(scrum: scrum)
        }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
