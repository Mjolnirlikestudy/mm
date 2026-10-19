import SwiftUI

struct BlockersView: View {
    @StateObject private var viewModel = BlockerListViewModel()
    @State private var isPresentingNewBlocker = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.blockers.isEmpty {
                    EmptyStateView(icon: "exclamationmark.triangle",
                                   title: "No blockers",
                                   message: "Tap + to report a blocker.")
                } else {
                    ForEach(viewModel.blockers) { blocker in
                        blockerCard(blocker)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Blockers")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingNewBlocker = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Blocker")
            }
        }
        .sheet(isPresented: $isPresentingNewBlocker) {
            NewBlockerSheet { title, relatedTask, group, owner, priority in
                viewModel.add(title: title,
                              relatedTask: relatedTask,
                              groupName: group,
                              owner: owner,
                              priority: priority)
            }
        }
    }

    private func blockerCard(_ blocker: BlockerItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(blocker.priority.tint)
                .frame(width: 10, height: 10)
                .padding(.top, 7)

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(blocker.title)
                        .font(.headline)
                    Spacer(minLength: 8)
                    StatusTag(text: blocker.priority.title, color: blocker.priority.tint)
                }

                Text("Related Task: \(blocker.relatedTask)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 14) {
                    Label(blocker.groupName, systemImage: "person.3")
                    Label(blocker.owner, systemImage: "person.crop.circle")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .cardBackground()
    }
}

#Preview {
    NavigationStack {
        BlockersView()
    }
}
