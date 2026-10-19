import SwiftUI

struct MeetingFooterView: View {
    let attendees: [String]
    let speakerIndex: Int
    let advanceSpeaker: () -> Void

    var body: some View {
        HStack {
            Text("Speaker \(min(speakerIndex + 1, attendees.count)) of \(attendees.count)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: advanceSpeaker) {
                Label("Next", systemImage: "forward.fill")
            }
            .buttonStyle(.borderedProminent)
            .accessibilityHint("Moves to the next speaker")
        }
        .padding(.horizontal)
    }
}

#Preview {
    MeetingFooterView(attendees: ["Cathy", "Daisy"], speakerIndex: 0) {}
        .padding()
}
