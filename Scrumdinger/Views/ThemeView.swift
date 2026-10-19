import SwiftUI

struct ThemeView: View {
    let theme: Theme
    var isSelected = false

    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(theme.main)
                .frame(width: 44, height: 44)
                .overlay {
                    Circle()
                        .strokeBorder(theme.accent, lineWidth: 2)
                }
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(theme.accent)
                    }
                }
                .overlay {
                    Circle()
                        .strokeBorder(theme.main, lineWidth: isSelected ? 3 : 0)
                        .padding(-4)
                }

            Text(theme.name)
                .font(.caption2)
                .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .frame(width: 60)
        .contentShape(Rectangle())
    }
}

#Preview {
    HStack {
        ThemeView(theme: .indigo)
        ThemeView(theme: .teal, isSelected: true)
        ThemeView(theme: .yellow)
    }
    .padding()
}
