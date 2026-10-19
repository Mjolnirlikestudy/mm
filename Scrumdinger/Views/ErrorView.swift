import SwiftUI

struct ErrorView: View {
    let errorWrapper: ErrorWrapper
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.yellow)

                Text("An error has occurred!")
                    .font(.title2.bold())

                Text(errorWrapper.error.localizedDescription)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(errorWrapper.guidance)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                Button("Dismiss") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Error")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ErrorView(errorWrapper: ErrorWrapper(error: CocoaError(.fileReadCorruptFile),
                                         guidance: "读取站会数据失败，请检查存储空间后重试。"))
}
