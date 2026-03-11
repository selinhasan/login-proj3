import Foundation

nonisolated struct UserProfile: Codable, Sendable {
    let id: String
    let username: String
    let email: String
    let profileImageName: String?
    let customProfileImageUrl: String?
    let bio: String?
    let status: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, username, email, bio, status
        case profileImageName = "profile_image_name"
        case customProfileImageUrl = "custom_profile_image_url"
        case createdAt = "created_at"
    }
}

nonisolated struct AuthResponse: Codable, Sendable {
    let token: String
    let user: UserProfile
}

nonisolated struct AuthErrorResponse: Codable, Sendable {
    let error: String?
    let message: String?
}

nonisolated struct LoginRequest: Codable, Sendable {
    let identifier: String
    let password: String
}

nonisolated struct RegisterRequest: Codable, Sendable {
    let username: String
    let email: String
    let password: String
}
