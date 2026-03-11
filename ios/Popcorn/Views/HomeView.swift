import SwiftUI

struct HomeView: View {
    let viewModel: AuthViewModel

    @State private var appeared: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.charcoal.ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    profileSection
                        .opacity(appeared ? 1 : 0)
                        .scaleEffect(appeared ? 1 : 0.9)

                    statsSection
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)

                    Spacer()

                    signOutButton
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)

                    Spacer()
                        .frame(height: 16)
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Text("🍿")
                            .font(.title3)
                        Text("Popcorn")
                            .font(.headline.bold())
                            .foregroundStyle(AppTheme.amber)
                    }
                }
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(AppTheme.charcoal, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.15)) {
                appeared = true
            }
        }
    }

    private var profileSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.amber.opacity(0.3), AppTheme.amberDark.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.amber)
            }

            VStack(spacing: 6) {
                Text("Welcome back,")
                    .font(.title3)
                    .foregroundStyle(AppTheme.subtleText)

                Text(viewModel.currentUser?.username ?? "Film Lover")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            statCard(icon: "film.fill", title: "Films", value: "0")
            statCard(icon: "star.fill", title: "Reviews", value: "0")
            statCard(icon: "list.bullet", title: "Lists", value: "0")
        }
    }

    private func statCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(AppTheme.amber)

            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(AppTheme.darkCard)
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.fieldBorder, lineWidth: 1)
        )
    }

    private var signOutButton: some View {
        Button {
            viewModel.signOut()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.subheadline)
                Text("Sign Out")
                    .font(.subheadline.bold())
            }
            .foregroundStyle(.red.opacity(0.9))
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color.red.opacity(0.1))
            .clipShape(.rect(cornerRadius: 14))
        }
        .sensoryFeedback(.impact(weight: .light), trigger: viewModel.isAuthenticated)
    }
}
