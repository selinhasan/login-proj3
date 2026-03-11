import SwiftUI

struct ContentView: View {
    @State private var viewModel = AuthViewModel()
    @State private var showRegister: Bool = false

    var body: some View {
        Group {
            if viewModel.isAuthenticated {
                HomeView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                if showRegister {
                    RegisterView(viewModel: viewModel) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            showRegister = false
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                } else {
                    LoginView(viewModel: viewModel) {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                            showRegister = true
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: viewModel.isAuthenticated)
        .preferredColorScheme(.dark)
    }
}
