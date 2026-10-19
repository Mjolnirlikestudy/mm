import SwiftUI

struct CardView: View {
    let scrum: DailyScrum

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(scrum.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 12)

            HStack {
                Label("\(scrum.attendees.count)", systemImage: "person.3")
                    .accessibilityLabel("\(scrum.attendees.count) attendees")
                Spacer()
                Label("\(scrum.lengthInMinutes) min", systemImage: "clock")
                    .accessibilityLabel("\(scrum.lengthInMinutes) minute meeting")
            }
            .font(.caption)
        }
        .padding()
        .foregroundStyle(scrum.theme.accent)
    }
}

#Preview {
    CardView(scrum: DailyScrum.sampleData[0])
        .background(DailyScrum.sampleData[0].theme.main)
        .previewLayout(.sizeThatFits)
}
