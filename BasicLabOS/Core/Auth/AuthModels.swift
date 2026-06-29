import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct AuthUser: Decodable {
    let userId: Int
    let username: String
    let nickname: String?
    let email: String?
    let phone: String?
    let isActive: Bool
    let isSuperuser: Bool
    let scopes: [String]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(Int.self, forKey: .userId)
        username = try container.decode(String.self, forKey: .username)
        nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        isSuperuser = try container.decodeIfPresent(Bool.self, forKey: .isSuperuser) ?? false
        scopes = try container.decodeIfPresent([String].self, forKey: .scopes) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case userId
        case username
        case nickname
        case email
        case phone
        case isActive
        case isSuperuser
        case scopes
    }
}

struct AuthSession: Decodable {
    let token: String
    let refreshToken: String?
    let user: AuthUser
}

struct UserData: Decodable {
    let user: AuthUser
}
