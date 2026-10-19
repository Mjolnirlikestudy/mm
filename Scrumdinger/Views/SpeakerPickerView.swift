import SwiftUI

/// 「下一位」弹窗：在还没发言的人里指定谁下一个说。
struct SpeakerPickerView: View {
    let attendees: [String]
    let activeIndex: Int
    let completedIndices: [Int]
    let onSelect: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    private func isFinished(_ index: Int) -> Bool {
        completedIndices.contains(index)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(attendees.indices, id: \.self) { index in
                        Button {
                            onSelect(index)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: iconName(for: index))
                                    .foregroundStyle(iconColor(for: index))
                                    .frame(width: 24)

                                Text(attendees[index])
                                    .foregroundStyle(index == activeIndex || isFinished(index) ? Color.secondary : Color.primary)

                                Spacer()

                                if index == activeIndex {
                                    Text("Speaking")
                                        .font(.caption)
                                        .foregroundStyle(.tint)
                                } else if isFinished(index) {
                                    Text("Spoken")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .disabled(index == activeIndex || isFinished(index))
                    }
                } footer: {
                    Text("Pick who speaks next. The clock keeps running.")
                }
            }
            .navigationTitle("Next Speaker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func iconName(for index: Int) -> String {
        if index == activeIndex { return "mic.fill" }
        if isFinished(index) { return "checkmark.circle.fill" }
        return "person.fill"
    }

    private func iconColor(for index: Int) -> Color {
        if index == activeIndex { return .accentColor }
        if isFinished(index) { return .green }
        return .secondary
    }
}

#Preview {
    SpeakerPickerView(attendees: ["Cathy", "Daisy", "Simon", "Jonathan"],
                      activeIndex: 0,
                      completedIndices: [3]) { _ in }
}
