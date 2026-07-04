import Foundation

struct Article: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let content: String?
    let image: String?
    let profile: ProfileSlim?
    let channelId: Int?
    let channelName: String?
    let commentsCount: Int?
    let votes: Release.Votes?
    let userVote: Int?
    let canEdit: Bool?
    let canDelete: Bool?
    let isPinned: Bool?
    let repostsCount: Int?
    let createdAt: String?
    let updatedAt: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
}

struct ArticleCompact: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let image: String?
    let profile: ProfileSlim?
    let channelName: String?
    let commentsCount: Int?
    let createdAt: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ArticleCompact, rhs: ArticleCompact) -> Bool {
        lhs.id == rhs.id
    }
}

struct Channel: Codable, Identifiable, Hashable {
    let id: Int
    let name: String?
    let description: String?
    let avatar: String?
    let cover: String?
    let profile: ProfileSlim?
    let subscribersCount: Int?
    let articlesCount: Int?
    let isSubscribed: Bool?
    let isMuted: Bool?
    let isBlocked: Bool?
    let createdAt: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
}

struct ChannelCompact: Codable, Identifiable {
    let id: Int
    let name: String?
    let avatar: String?
}
