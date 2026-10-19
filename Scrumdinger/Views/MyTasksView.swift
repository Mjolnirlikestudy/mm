import SwiftUI

struct MyTasksView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var isPresentingNewTask = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if viewModel.tasks.isEmpty {
                    EmptyStateView(icon: "checklist",
                                   title: "No tasks yet",
                                   message: "Tap + to create your first task.")
                } else {
                    ForEach(viewModel.tasks) { task in
                        taskCard(task)
                    }
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("My Tasks")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isPresentingNewTask = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New Task")
            }
        }
        .sheet(isPresented: $isPresentingNewTask) {
            NewTaskSheet { title, group, status, dueDate in
                viewModel.add(title: title, groupName: group, status: status, dueDate: dueDate)
            }
        }
    }

    private func taskCard(_ task: TaskItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(task.title)
                    .font(.headline)
                Spacer(minLength: 8)
                StatusTag(text: task.status.title, color: task.status.tint)
            }

            HStack(spacing: 14) {
                Label(task.groupName, systemImage: "person.3")
                Label("Due \(task.dueDate.formatted(date: .abbreviated, time: .omitted))",
                      systemImage: "calendar")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .cardBackground()
    }
}

#Preview {
    NavigationStack {
        MyTasksView()
    }
}
