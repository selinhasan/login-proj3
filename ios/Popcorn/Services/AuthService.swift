import Foundation

nonisolated enum AuthServiceError: LocalizedError, Sendable {
    case invalidURL
    case networkError(String)
    case serverError(String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid server URL"
        case .networkError(let msg): msg
        case .serverError(let msg): msg
        case .decodingError: "Unexpected server response"
        }
    }
}

actor AuthService {
    static let shared = AuthService()
    private let baseURL = "https://rork-popcorn-film-log.vercel.app"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    func login(identifier: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(identifier: identifier, password: password)
        return try await post(path: "/api/login", body: body)
    }

    func register(username: String, email: String, password: String) async throws -> AuthResponse {
        let body = RegisterRequest(username: username, email: email, password: password)
        return try await post(path: "/api/register", body: body)
    }

    private func post<T: Encodable, R: Decodable>(path: String, body: T) async throws -> R {
        guard let url = URL(string: baseURL + path) else {
            throw AuthServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 15

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw AuthServiceError.networkError("Unable to connect. Check your internet connection.")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthServiceError.networkError("Invalid response from server.")
        }

        if httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 {
            do {
                return try decoder.decode(R.self, from: data)
            } catch {
                throw AuthServiceError.decodingError
            }
        }

        if let errorResponse = try? decoder.decode(AuthErrorResponse.self, from: data) {
            let message = errorResponse.error ?? errorResponse.message ?? "Something went wrong."
            throw AuthServiceError.serverError(message)
        }

        throw AuthServiceError.serverError("Server error (\(httpResponse.statusCode))")
    }
}
