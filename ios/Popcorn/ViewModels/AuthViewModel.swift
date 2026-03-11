import Foundation
import SwiftUI

@Observable
@MainActor
class AuthViewModel {
    var isAuthenticated: Bool = false
    var currentUser: UserProfile?
    var isLoading: Bool = false
    var errorMessage: String?

    var loginIdentifier: String = ""
    var loginPassword: String = ""

    var registerUsername: String = ""
    var registerEmail: String = ""
    var registerPassword: String = ""
    var registerConfirmPassword: String = ""

    private let authService = AuthService.shared

    init() {
        restoreSession()
    }

    private func restoreSession() {
        if let token = KeychainService.getToken(), !token.isEmpty,
           let user = KeychainService.getUser() {
            currentUser = user
            isAuthenticated = true
        }
    }

    var canLogin: Bool {
        !loginIdentifier.trimmingCharacters(in: .whitespaces).isEmpty &&
        !loginPassword.isEmpty
    }

    var canRegister: Bool {
        !registerUsername.trimmingCharacters(in: .whitespaces).isEmpty &&
        !registerEmail.trimmingCharacters(in: .whitespaces).isEmpty &&
        registerPassword.count >= 6 &&
        registerPassword == registerConfirmPassword
    }

    var registerValidationMessage: String? {
        if !registerEmail.isEmpty && !isValidEmail(registerEmail) {
            return "Please enter a valid email address"
        }
        if !registerPassword.isEmpty && registerPassword.count < 6 {
            return "Password must be at least 6 characters"
        }
        if !registerConfirmPassword.isEmpty && registerPassword != registerConfirmPassword {
            return "Passwords don't match"
        }
        return nil
    }

    func login() async {
        guard canLogin else { return }
        isLoading = true
        errorMessage = nil

        do {
            let response = try await authService.login(
                identifier: loginIdentifier.trimmingCharacters(in: .whitespaces),
                password: loginPassword
            )
            KeychainService.saveToken(response.token)
            KeychainService.saveUser(response.user)
            currentUser = response.user
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isAuthenticated = true
            }
            loginIdentifier = ""
            loginPassword = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func register() async {
        guard canRegister else { return }
        isLoading = true
        errorMessage = nil

        do {
            let response = try await authService.register(
                username: registerUsername.trimmingCharacters(in: .whitespaces),
                email: registerEmail.trimmingCharacters(in: .whitespaces).lowercased(),
                password: registerPassword
            )
            KeychainService.saveToken(response.token)
            KeychainService.saveUser(response.user)
            currentUser = response.user
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isAuthenticated = true
            }
            registerUsername = ""
            registerEmail = ""
            registerPassword = ""
            registerConfirmPassword = ""
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func signOut() {
        KeychainService.clearAll()
        currentUser = nil
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isAuthenticated = false
        }
        errorMessage = nil
    }

    func clearError() {
        errorMessage = nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
