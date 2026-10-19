import SwiftUI

struct MeetingView: View {
    @Binding var scrum: DailyScrum
    @State private var secondsElapsed = 0
    @State private var speakerIndex = 0

    private var secondsRemaining: Int {
        max(scrum.lengthInMinutes * 60 - secondsElapsed, 0)
    }

    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(secondsElapsed),
                         total: Double(scrum.lengthInMinutes * 60))
                .padding(.horizontal)

            MeetingHeaderView(secondsRemaining: secondsRemaining,
                              numberOfAttendees: scrum.attendees.count)

            MeetingTimerView(attendees: scrum.attendees,
                             speakerIndex: speakerIndex)

            MeetingFooterView(attendees: scrum.attendees,
                              speakerIndex: speakerIndex) {
                advanceSpeaker()
            }
        }
        .padding(.vertical)
        .navigationTitle(scrum.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func advanceSpeaker() {
        speakerIndex = (speakerIndex + 1) % max(scrum.attendees.count, 1)
    }
}

#Preview {
    NavigationStack {
        MeetingView(scrum: .constant(DailyScrum.sampleData[1]))
    }
}
