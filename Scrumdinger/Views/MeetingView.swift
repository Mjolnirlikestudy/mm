import SwiftUI

struct MeetingView: View {
    @State private var secondsElapsed = 0
    @State private var speakerIndex = 0

    private let lengthInMinutes = 5
    private let attendees = ["Cathy", "Daisy", "Simon", "Jonathan"]

    private var secondsRemaining: Int {
        max(lengthInMinutes * 60 - secondsElapsed, 0)
    }

    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(secondsElapsed),
                         total: Double(lengthInMinutes * 60))
                .padding(.horizontal)

            MeetingHeaderView(secondsRemaining: secondsRemaining,
                              numberOfAttendees: attendees.count)

            MeetingTimerView(attendees: attendees,
                             speakerIndex: speakerIndex)

            MeetingFooterView(attendees: attendees,
                              speakerIndex: speakerIndex) {
                advanceSpeaker()
            }
        }
        .padding(.vertical)
    }

    private func advanceSpeaker() {
        speakerIndex = (speakerIndex + 1) % attendees.count
    }
}

#Preview {
    MeetingView()
}
