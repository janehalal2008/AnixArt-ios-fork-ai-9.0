import Foundation

struct HistoryItem: Codable, Identifiable {
    let id: Int
    let releaseId: Int?
    let releaseName: String?
    let poster: Release.Poster?
    let episodeId: Int?
    let episodeName: String?
    let position: Int?
    let sourceId: Int?
    let updatedAt: String?
}

struct HistoryResponse: Codable {
    let history: [HistoryItem]?
    let message: String?
}

struct Favorite: Codable, Identifiable {
    let id: Int
    let release: ReleaseCompact?
    let profileId: Int
    let status: String?
    let updatedAt: String?
}

struct FavoritesResponse: Codable {
    let favorites: [Favorite]?
    let message: String?
}

struct NotificationItem: Codable, Identifiable {
    let id: Int
    let type: String?
    let profile: ProfileSlim?
    let releaseId: Int?
    let releaseName: String?
    let poster: Release.Poster?
    let episodePosition: Int?
    let episodeName: String?
    let commentId: Int?
    let commentText: String?
    let articleId: Int?
    let articleTitle: String?
    let collectionId: Int?
    let collectionName: String?
    let createdAt: String?
    let read: Bool?
}

struct NotificationCountResponse: Codable {
    let count: Int?
}

struct TogglesResponse: Codable {
    let baseUrl: String?
    let kodikVideoLinksUrl: String?
    let kodikAdIframeUrl: String?
    let iframeEmbedUrl: String?
    let torlookUrl: String?
    let sibnetUserAgent: String?
    let sibnetRandUserAgent: Bool?
    let codecProfile: String?
    let editorUrl: String?
    let authAvailable: Bool?
    let googleAuth: Bool?
    let vkAuth: Bool?
    let telegramAuth: Bool?
    let altConnectionMode: Bool?
    let staticDomain: String?
    let updateUrl: String?
}

struct ConfigUrlsResponse: Codable {
    let apiUrls: [String]?
    let editorUrl: String?
    let staticDomain: String?
    let authAvailable: Bool?
    let googleAuth: Bool?
    let vkAuth: Bool?
    let telegramAuth: Bool?
}

struct PaginatedResponse<T: Codable>: Codable {
    let items: [T]?
    let page: Int?
    let totalPages: Int?
    let totalItems: Int?
}
