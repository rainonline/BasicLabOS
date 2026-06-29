import Foundation
import Security

struct StoredSession: Codable, Equatable {
    let accessToken: String
    let refreshToken: String?
    let userId: Int
    let username: String
    let displayName: String

    init(session: AuthSession) {
        accessToken = session.token
        refreshToken = session.refreshToken
        userId = session.user.userId
        username = session.user.username
        displayName = session.user.nickname?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            ?? session.user.username
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

enum SessionStore {
    private static let service = "com.basiclabx.BasicLabOS.session"
    private static let account = "current"

    static func save(_ session: StoredSession) throws {
        let data = try JSONEncoder().encode(session)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw SessionStoreError.unhandledStatus(addStatus)
            }
            return
        }

        guard status == errSecSuccess else {
            throw SessionStoreError.unhandledStatus(status)
        }
    }

    static func load() throws -> StoredSession? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw SessionStoreError.unhandledStatus(status)
        }
        guard let data = item as? Data else {
            return nil
        }
        return try JSONDecoder().decode(StoredSession.self, from: data)
    }

    static func clear() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum SessionStoreError: LocalizedError {
    case unhandledStatus(OSStatus)

    var errorDescription: String? {
        switch self {
        case let .unhandledStatus(status):
            "无法保存登录状态（\(status)）。"
        }
    }
}
