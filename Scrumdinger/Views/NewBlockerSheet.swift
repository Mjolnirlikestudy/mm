import SwiftUI

struct NewBlockerSheet: View {
    let onSave: (String, String, String, String, BlockerPriority) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var relatedTask = ""
    @State private var group = ""
    @State private var owner = ""
    @State private var priority: BlockerPriority = .normal

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Blocker") {
                    TextField("Title", text: $title)
                    TextField("Related Task", text: $relatedTask)
                }

                Section {
                    TextField("Group", text: $group)
                    TextField("Owner", text: $owner)
                    Picker("Priority", selection: $priority) {
                        ForEach(BlockerPriority.allCases) { priority in
                            Text(priority.title).tag(priority)
                        }
                    }
                }
            }
            .navigationTitle("New Blocker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, relatedTask, group, owner, priority)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}

#Preview {
    NewBlockerSheet { _, _, _, _, _ in }
}
