import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel
    var onSwitchToLogin: () -> Void

    @State private var appeared: Bool = false

    enum FocusField { case username, email, password, confirmPassword }
    @FocusState private var focusedField: FocusField?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 48)

                headerSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Spacer()
                    .frame(height: 40)

                fieldsSection
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)

                Spacer()
                    .frame(height: 8)

                validationSection

                Spacer()
                    .frame(height: 8)

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
            Text("🎬")
                .font(.system(size: 48))

            Text("Join Popcorn")
                .font(.system(size: 34, weight: .black, design: .default))
                .foregroundStyle(AppTheme.titleGradient)

            Text("Start logging your film journey")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
        }
    }

    private var fieldsSection: some View {
        VStack(spacing: 14) {
            ThemedTextField(
                placeholder: "Username",
                text: $viewModel.registerUsername,
                icon: "at",
                textContentType: .username
            )
            .focused($focusedField, equals: .username)
            .submitLabel(.next)
            .onSubmit { focusedField = .email }

            ThemedTextField(
                placeholder: "Email",
                text: $viewModel.registerEmail,
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            ThemedSecureField(
                placeholder: "Password (min 6 characters)",
                text: $viewModel.registerPassword,
                textContentType: .newPassword
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit { focusedField = .confirmPassword }

            ThemedSecureField(
                placeholder: "Confirm password",
                text: $viewModel.registerConfirmPassword,
                textContentType: .newPassword
            )
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit {
                if viewModel.canRegister {
                    Task { await viewModel.register() }
                }
            }
        }
    }

    private var validationSection: some View {
        Group {
            if let message = viewModel.registerValidationMessage {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                    Text(message)
                        .font(.caption)
                }
                .foregroundStyle(AppTheme.amber.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
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
            title: "Create Account",
            isLoading: viewModel.isLoading,
            isEnabled: viewModel.canRegister
        ) {
            focusedField = nil
            Task { await viewModel.register() }
        }
    }

    private var footerSection: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)

            Button("Sign in") {
                viewModel.clearError()
                onSwitchToLogin()
            }
            .font(.subheadline.bold())
            .foregroundStyle(AppTheme.amber)
        }
    }
}
