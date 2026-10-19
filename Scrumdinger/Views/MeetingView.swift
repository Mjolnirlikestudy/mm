import SwiftUI

struct MeetingView: View {
    @Binding var scrum: DailyScrum
    @StateObject private var timer: ScrumTimer
    @StateObject private var recorder = AudioRecorder()
    @Environment(\.dismiss) private var dismiss
    @State private var isSelectingSpeaker = false

    init(scrum: Binding<DailyScrum>) {
        _scrum = scrum
        let value = scrum.wrappedValue
        _timer = StateObject(wrappedValue: ScrumTimer(lengthInMinutes: value.lengthInMinutes,
                                                      attendees: value.attendees))
    }

    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: Double(timer.secondsElapsed),
                         total: Double(max(timer.totalSeconds, 1)))
                .tint(scrum.theme.main)
                .padding(.horizontal)

            MeetingHeaderView(secondsElapsed: timer.secondsElapsed,
                              secondsRemaining: timer.secondsRemaining,
                              numberOfAttendees: scrum.attendees.count)

            MeetingTimerView(attendees: scrum.attendees,
                             speakerIndex: timer.activeSpeakerIndex,
                             secondsElapsed: timer.secondsElapsed,
                             spans: timer.speakerSpans(),
                             totalSeconds: timer.totalSeconds,
                             mainColor: scrum.theme.main,
                             accentColor: scrum.theme.accent)

            MeetingFooterView(attendees: scrum.attendees,
                              speakerIndex: timer.activeSpeakerIndex) {
                isSelectingSpeaker = true
            }
        }
        .padding(.vertical)
        .navigationTitle(scrum.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    recorder.toggle()
                } label: {
                    Image(systemName: recorder.isRecording ? "mic.fill" : "mic")
                        .foregroundStyle(recorder.isRecording ? .red : .primary)
                }
                .accessibilityLabel(recorder.isRecording ? "Stop recording" : "Start recording")

                Button("End", role: .destructive) {
                    endMeeting()
                }
            }
        }
        .onAppear {
            timer.onSpeakerCompleted = {
                DingPlayer.shared.play()
            }
            timer.start()
        }
        .onDisappear {
            timer.stop()
            recorder.stop()
        }
        .onChange(of: timer.isFinished) { isFinished in
            if isFinished {
                endMeeting()
            }
        }
        .alert(item: $recorder.alert) { alert in
            Alert(title: Text("Recording"),
                  message: Text(alert.message),
                  dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $isSelectingSpeaker) {
            SpeakerPickerView(attendees: scrum.attendees,
                              activeIndex: timer.activeSpeakerIndex,
                              completedIndices: timer.completedSpeakerIndices) { index in
                timer.selectSpeaker(index)
            }
        }
    }

    /// 结束会议：停止录音，把本次会议写入历史记录并返回详情页。
    private func endMeeting() {
        timer.stop()
        recorder.stop()
        if timer.secondsElapsed > 0 {
            scrum.history.append(History(attendees: scrum.attendees,
                                         lengthInMinutes: scrum.lengthInMinutes,
                                         recordingFileName: recorder.lastRecordingFileName))
        }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MeetingView(scrum: .constant(DailyScrum.sampleData[1]))
    }
}
