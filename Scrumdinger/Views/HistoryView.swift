import SwiftUI

struct HistoryView: View {
    let history: History

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Label(history.date.formatted(date: .abbreviated, time: .shortened),
                      systemImage: "calendar")
                    .font(.headline)

                HStack {
                    Label("\(history.attendees.count) attendees", systemImage: "person.3")
                    Spacer()
                    Label("\(history.lengthInMinutes) min", systemImage: "clock")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                Divider()

                Text(history.transcript.isEmpty ? "No transcript" : history.transcript)
                    .textSelection(.enabled)
            }
            .padding()
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HistoryView(history: History(attendees: ["Cathy", "Daisy"],
                                     lengthInMinutes: 10,
                                     transcript: "Yesterday we finished the design review."))
    }
}
