import SwiftUI

enum AppTheme {
    static let amber = Color(red: 0.96, green: 0.76, blue: 0.28)
    static let amberDark = Color(red: 0.82, green: 0.62, blue: 0.15)
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.4)
    static let charcoal = Color(red: 0.09, green: 0.09, blue: 0.11)
    static let darkCard = Color(red: 0.13, green: 0.13, blue: 0.15)
    static let darkField = Color(red: 0.16, green: 0.16, blue: 0.18)
    static let fieldBorder = Color.white.opacity(0.08)
    static let subtleText = Color.white.opacity(0.5)

    static let titleGradient = LinearGradient(
        colors: [gold, amber],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let buttonGradient = LinearGradient(
        colors: [amber, amberDark],
        startPoint: .top,
        endPoint: .bottom
    )
}
