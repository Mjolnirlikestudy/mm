import SwiftUI

struct DetailEditView: View {
    private let onSave: (DailyScrum) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var draft: DailyScrum

    init(scrum: DailyScrum, onSave: @escaping (DailyScrum) -> Void) {
        _draft = State(initialValue: scrum)
        self.onSave = onSave
    }

    /// 参会者以「逗号分隔的字符串」编辑，保存时再拆回数组。
    private var attendeesText: Binding<String> {
        Binding {
            draft.attendees.joined(separator: ", ")
        } set: { newValue in
            draft.attendees = newValue
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
    }

    private var isTitleEmpty: Bool {
        draft.title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            Section("Meeting Info") {
                TextField("Title", text: $draft.title)
                TextField("Attendees", text: attendeesText)
                Stepper(value: $draft.lengthInMinutes, in: 5...30, step: 5) {
                    Text("\(draft.lengthInMinutes) minutes")
                }
            }

            Section("Theme") {
                ThemePicker(selection: $draft.theme)
                    .padding(.vertical, 4)
            }
        }
        .navigationTitle(isTitleEmpty ? "New Scrum" : draft.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    onSave(draft)
                    dismiss()
                }
                .disabled(isTitleEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailEditView(scrum: DailyScrum.sampleData[0]) { _ in }
    }
}
