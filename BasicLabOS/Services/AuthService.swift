import Foundation

struct AuthService {
    private let client: APIClient

    nonisolated init(client: APIClient = APIClient()) {
        self.client = client
    }

    func login(username: String, password: String) async throws -> AuthSession {
        try await client.request(
            path: "/api/v1/users/login",
            method: .post,
            body: LoginRequest(username: username, password: password),
            auth: .none
        )
    }

    func currentUser(accessToken: String) async throws -> AuthUser {
        let data: UserData = try await client.request(
            path: "/api/v1/users/me",
            auth: .bearer(accessToken)
        )
        return data.user
    }

    func logout(accessToken: String) async throws {
        let _: EmptyResponse = try await client.request(
            path: "/api/v1/users/logout",
            method: .post,
            auth: .bearer(accessToken)
        )
    }
}

private struct EmptyResponse: Decodable {}
