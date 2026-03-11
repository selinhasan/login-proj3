import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.black)
                        .scaleEffect(0.85)
                } else {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                isEnabled ? AppTheme.buttonGradient : LinearGradient(
                    colors: [AppTheme.amber.opacity(0.3), AppTheme.amberDark.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundStyle(isEnabled ? .black : .black.opacity(0.4))
            .clipShape(.rect(cornerRadius: 14))
        }
        .disabled(!isEnabled || isLoading)
        .sensoryFeedback(.impact(weight: .medium), trigger: isLoading)
    }
}
