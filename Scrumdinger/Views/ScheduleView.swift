import SwiftUI

struct ScheduleView: View {
    @StateObject private var viewModel = ScheduleViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                Text("Today")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ForEach(viewModel.meetings) { meeting in
                    meetingCard(meeting)
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.large)
    }

    private func meetingCard(_ meeting: MeetingEvent) -> some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(meeting.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.title3.bold())
                    .monospacedDigit()
                Text("Today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 64, alignment: .leading)

            Rectangle()
                .fill(Color.orange.opacity(0.4))
                .frame(width: 2, height: 36)
                .clipShape(Capsule())

            VStack(alignment: .leading, spacing: 6) {
                Text(meeting.title)
                    .font(.headline)
                Label(meeting.groupName, systemImage: "person.3")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Button {
                viewModel.join(meeting)
            } label: {
                Text(meeting.isJoined ? "Joined" : "Join")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(meeting.isJoined ? Color.secondary.opacity(0.12) : Color.accentColor)
                    .foregroundStyle(meeting.isJoined ? Color.secondary : Color.white)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(meeting.isJoined)
        }
        .cardBackground()
    }
}

#Preview {
    NavigationStack {
        ScheduleView()
    }
}
