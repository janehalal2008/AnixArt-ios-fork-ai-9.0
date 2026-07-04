import Foundation

struct Profile: Codable, Identifiable, Hashable {
    let id: Int
    let login: String?
    let avatar: String?
    let avatarBig: String?
    let role: ProfileRole?
    let followed: Bool?
    let followerCount: Int?
    let followingCount: Int?
    let status: String?
    let customStatus: String?
    let description: String?
    let addedAt: String?
    let lastSeenAt: String?
    let online: Bool?

    enum ProfileRole: String, Codable {
        case user = "USER"
        case admin = "ADMIN"
        case moderator = "MODERATOR"
        case editor = "EDITOR"
        case sponsor = "SPONSOR"
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Profile, rhs: Profile) -> Bool {
        lhs.id == rhs.id
    }
}

struct ProfileSlim: Codable, Identifiable, Hashable {
    let id: Int
    let login: String?
    let avatar: String?
    let role: Profile.ProfileRole?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ProfileSlim, rhs: ProfileSlim) -> Bool {
        lhs.id == rhs.id
    }
}

struct ProfileToken: Codable {
    let token: String?
    let profile: Profile?
}

struct SignInResponse: Codable {
    let token: String?
    let profile: Profile?
    let message: String?
}

struct SignUpResponse: Codable {
    let message: String?
}

struct VerifyResponse: Codable {
    let token: String?
    let message: String?
}

struct GoogleResponse: Codable {
    let token: String?
    let message: String?
}

struct TelegramResponse: Codable {
    let token: String?
    let message: String?
}

struct VkResponse: Codable {
    let token: String?
    let message: String?
}

struct FirebaseResponse: Codable {
    let token: String?
    let message: String?
}

struct CheckLoginResponse: Codable {
    let available: Bool?
    let message: String?
}
