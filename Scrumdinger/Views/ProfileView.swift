import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isShowingSignOutAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    profileHeader
                    quickActions
                    settingsCard
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Me")
            .alert("Sign Out", isPresented: $isShowingSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {}
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 14) {
            Image(systemName: viewModel.profile.avatarSystemName)
                .font(.system(size: 42))
                .foregroundStyle(.white)
                .frame(width: 72, height: 72)
                .background(
                    LinearGradient(colors: [.blue, .teal],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.profile.name)
                    .font(.title3.bold())
                Text(viewModel.displayRole)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .cardBackground()
    }

    private var quickActions: some View {
        HStack(spacing: 8) {
            quickLink(icon: "checklist", title: "My Tasks", tint: .blue) {
                MyTasksView()
            }
            quickLink(icon: "calendar", title: "Schedule", tint: .orange) {
                ScheduleView()
            }
            quickLink(icon: "exclamationmark.triangle.fill", title: "Blockers", tint: .red) {
                BlockersView()
            }
            quickLink(icon: "doc.text", title: "Meeting Notes", tint: .green) {
                MeetingNotesView()
            }
        }
        .cardBackground()
    }

    private var settingsCard: some View {
        VStack(spacing: 0) {
            settingsRow(icon: "gearshape", title: "Account Settings") {
                AccountSettingsView()
            }
            Divider().padding(.leading, 44)
            settingsRow(icon: "bell", title: "Notifications") {
                NotificationSettingsView()
            }
            Divider().padding(.leading, 44)
            settingsRow(icon: "info.circle", title: "About") {
                AboutView()
            }
            Divider().padding(.leading, 44)

            Button {
                isShowingSignOutAlert = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(.red)
                        .frame(width: 24)
                    Text("Sign Out")
                        .foregroundStyle(.red)
                    Spacer()
                }
                .contentShape(Rectangle())
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
        }
        .cardBackground()
    }

    private func quickLink<Destination: View>(icon: String,
                                             title: LocalizedStringKey,
                                             tint: Color,
                                             @ViewBuilder destination: @escaping () -> Destination) -> some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                QuickActionIcon(systemName: icon, tint: tint)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    private func settingsRow<Destination: View>(icon: String,
                                               title: LocalizedStringKey,
                                               @ViewBuilder destination: @escaping () -> Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 24)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileView()
}
