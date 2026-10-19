import SwiftUI

struct DetailView: View {
    @Binding var scrum: DailyScrum
    @State private var isPresentingEditView = false

    var body: some View {
        List {
            Section {
                NavigationLink {
                    MeetingView(scrum: $scrum)
                } label: {
                    Label("Start Meeting", systemImage: "timer")
                        .font(.headline)
                }

                HStack {
                    Label("Length", systemImage: "clock")
                    Spacer()
                    Text("\(scrum.lengthInMinutes) minutes")
                }
                .accessibilityElement(children: .combine)

                HStack {
                    Label("Theme", systemImage: "paintpalette")
                    Spacer()
                    Text(scrum.theme.name)
                        .padding(4)
                        .foregroundStyle(scrum.theme.accent)
                        .background(scrum.theme.main)
                        .clipShape(Capsule())
                }
                .accessibilityElement(children: .combine)
            } header: {
                Text("Meeting Info")
            }

            Section("Attendees") {
                ForEach(scrum.attendees, id: \.self) { attendee in
                    Text(attendee)
                }
            }

            Section("History") {
                if scrum.history.isEmpty {
                    Text("No history yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(scrum.history) { history in
                        NavigationLink {
                            HistoryView(history: history)
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text(history.date, style: .date)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(scrum.title)
        .toolbar {
            Button("Edit") {
                isPresentingEditView = true
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                DetailEditView(scrum: scrum) { updatedScrum in
                    scrum = updatedScrum
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailView(scrum: .constant(DailyScrum.sampleData[0]))
    }
}
