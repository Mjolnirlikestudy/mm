import SwiftUI

struct MeetingNotesView: View {
    @StateObject private var viewModel = RetroListViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.notes.isEmpty {
                    EmptyStateView(icon: "doc.text",
                                   title: "No meeting notes yet",
                                   message: "Notes appear after each daily scrum.")
                } else {
                    ForEach(viewModel.notes) { note in
                        noteCard(note)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Meeting Notes")
        .navigationBarTitleDisplayMode(.large)
    }

    private func noteCard(_ note: RetroNote) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.groupName)
                    .font(.headline)
                Spacer()
                Text(note.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(note.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .cardBackground()
    }
}

#Preview {
    NavigationStack {
        MeetingNotesView()
    }
}
