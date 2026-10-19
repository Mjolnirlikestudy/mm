import SwiftUI

struct AccountSettingsView: View {
    @State private var isShowingPasswordAlert = false

    var body: some View {
        Form {
            Section("Account") {
                LabeledContent("Name", value: "萌萌")
                LabeledContent("Email", value: "2678659042@qq.com")
                LabeledContent("Role", value: "敏捷教练")
            }

            Section {
                Button("Change Password") {
                    isShowingPasswordAlert = true
                }
            }
        }
        .navigationTitle("Account Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Password Reset", isPresented: $isShowingPasswordAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A reset link has been sent to your email.")
        }
    }
}

struct NotificationSettingsView: View {
    @AppStorage("notifyMeetings") private var notifyMeetings = true
    @AppStorage("notifyBlockers") private var notifyBlockers = true
    @AppStorage("notifyDailySummary") private var notifyDailySummary = false

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Meeting reminders", isOn: $notifyMeetings)
                Toggle("Blocker alerts", isOn: $notifyBlockers)
                Toggle("Daily summary", isOn: $notifyDailySummary)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Image(systemName: "timer")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 96, height: 96)
                    .background(
                        LinearGradient(colors: [.blue, .teal],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

                Text("Scrumdinger")
                    .font(.title2.bold())

                Text("Version \(version)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text("A lightweight daily scrum timer for agile teams. Keep every stand-up short, focused, and on time.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Link("App Dev Tutorials",
                     destination: URL(string: "https://developer.apple.com/tutorials/app-dev-training")!)
                    .font(.footnote)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AccountSettingsView()
    }
}
