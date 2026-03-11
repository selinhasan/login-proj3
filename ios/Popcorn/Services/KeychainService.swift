import Foundation
import Security

enum KeychainService {
    private static let tokenKey = "com.popcorn.authToken"
    private static let userKey = "com.popcorn.userData"

    static func saveToken(_ token: String) {
        save(key: tokenKey, data: Data(token.utf8))
    }

    static func getToken() -> String? {
        guard let data = load(key: tokenKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func saveUser(_ user: UserProfile) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        save(key: userKey, data: data)
    }

    static func getUser() -> UserProfile? {
        guard let data = load(key: userKey) else { return nil }
        return try? JSONDecoder().decode(UserProfile.self, from: data)
    }

    static func clearAll() {
        delete(key: tokenKey)
        delete(key: userKey)
    }

    private static func save(key: String, data: Data) {
        delete(key: key)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    private static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
