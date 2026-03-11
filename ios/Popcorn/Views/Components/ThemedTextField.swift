import SwiftUI

struct ThemedTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(AppTheme.subtleText)
                .frame(width: 20)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(AppTheme.subtleText))
                .foregroundStyle(.white)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
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
