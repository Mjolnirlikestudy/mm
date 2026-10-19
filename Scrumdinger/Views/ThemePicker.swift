import SwiftUI

struct ThemePicker: View {
    @Binding var selection: Theme

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Theme.allCases) { theme in
                    Button {
                        selection = theme
                    } label: {
                        ThemeView(theme: theme, isSelected: theme.name == selection.name)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(theme.name)
                    .accessibilityAddTraits(theme.name == selection.name ? .isSelected : [])
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ThemePicker(selection: .constant(.teal))
        .padding()
}
