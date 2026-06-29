import Foundation
import Observation

@Observable
@MainActor
final class AuthSessionStore {
    private(set) var session: StoredSession?
    private(set) var isRestoring = true

    var isAuthenticated: Bool {
        session != nil
    }

    var accessToken: String? {
        session?.accessToken
    }

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func restore() async {
        defer { isRestoring = false }

        guard let stored = try? SessionStore.load() else {
            session = nil
            return
        }

        do {
            _ = try await authService.currentUser(accessToken: stored.accessToken)
            session = stored
        } catch {
            SessionStore.clear()
            session = nil
        }
    }

    func login(username: String, password: String) async throws {
        let response = try await authService.login(username: username, password: password)
        let stored = StoredSession(session: response)
        try SessionStore.save(stored)
        session = stored
    }

    func logout() async {
        if let token = session?.accessToken {
            try? await authService.logout(accessToken: token)
        }
        SessionStore.clear()
        session = nil
    }
}
