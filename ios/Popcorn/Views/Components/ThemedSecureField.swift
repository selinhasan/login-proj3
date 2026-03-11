import SwiftUI

struct ThemedSecureField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isRevealed: Bool = false
    var textContentType: UITextContentType?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .font(.body)
                .foregroundStyle(AppTheme.subtleText)
                .frame(width: 20)

            Group {
                if isRevealed {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppTheme.subtleText))
                        .textContentType(textContentType)
                } else {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppTheme.subtleText))
                        .textContentType(textContentType)
                }
            }
            .foregroundStyle(.white)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                    .font(.body)
                    .foregroundStyle(AppTheme.subtleText)
                    .contentTransition(.symbolEffect(.replace))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.darkField)
        .clipShape(.rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(AppTheme.fieldBorder, lineWidth: 1)
        )
    }
}
