import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    var onSwitchToRegister: () -> Void

    @State private var appeared: Bool = false

    enum FocusField { case identifier, password }
    @FocusState private var focusedField: FocusField?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 60)

                headerSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Spacer()
                    .frame(height: 48)

                fieldsSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Spacer()
                    .frame(height: 12)

                errorSection

                Spacer()
                    .frame(height: 24)

                actionSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Spacer()
                    .frame(height: 40)

                footerSection
                    .opacity(appeared ? 1 : 0)
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppTheme.charcoal.ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
            viewModel.clearError()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🍿")
                .font(.system(size: 56))

            Text("Popcorn")
                .font(.system(size: 38, weight: .black, design: .default))
                .foregroundStyle(AppTheme.titleGradient)

            Text("Your personal film log")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
        }
    }

    private var fieldsSection: some View {
        VStack(spacing: 14) {
            ThemedTextField(
                placeholder: "Email or username",
                text: $viewModel.loginIdentifier,
                icon: "person.fill",
                keyboardType: .emailAddress,
                textContentType: .username
            )
            .focused($focusedField, equals: .identifier)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            ThemedSecureField(
                placeholder: "Password",
                text: $viewModel.loginPassword,
                textContentType: .password
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit {
                if viewModel.canLogin {
                    Task { await viewModel.login() }
                }
            }
        }
    }

    private var errorSection: some View {
        Group {
            if let error = viewModel.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.subheadline)
                    Text(error)
                        .font(.subheadline)
                }
                .foregroundStyle(.red)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.red.opacity(0.1))
                .clipShape(.rect(cornerRadius: 10))
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .animation(.spring(response: 0.3), value: viewModel.errorMessage)
            }
        }
    }

    private var actionSection: some View {
        PrimaryButton(
            title: "Sign In",
            isLoading: viewModel.isLoading,
            isEnabled: viewModel.canLogin
        ) {
            focusedField = nil
            Task { await viewModel.login() }
        }
    }

    private var footerSection: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)

            Button("Create one") {
                viewModel.clearError()
                onSwitchToRegister()
            }
            .font(.subheadline.bold())
            .foregroundStyle(AppTheme.amber)
        }
    }
}
