import AVFoundation
import SwiftUI

struct HistoryView: View {
    let history: History
    @State private var audioPlayer: AVAudioPlayer?

    private var recordingURL: URL? {
        guard let fileName = history.recordingFileName else { return nil }
        let url = RecordingStorage.url(for: fileName)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

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

                if let recordingURL {
                    Button {
                        audioPlayer = try? AVAudioPlayer(contentsOf: recordingURL)
                        audioPlayer?.play()
                    } label: {
                        Label("Play Recording", systemImage: "play.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityHint("Plays the audio recorded during this meeting")
                }

                Divider()

                Text(history.transcript.isEmpty
                     ? String(localized: "No transcript")
                     : history.transcript)
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
