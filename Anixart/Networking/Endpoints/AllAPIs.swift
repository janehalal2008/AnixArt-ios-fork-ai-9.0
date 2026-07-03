import Foundation

struct ProfileAPI {
    private let api = APIClient.shared

    func getProfile(id: Int) async throws -> Profile {
        try await api.request("profile/\(id)")
    }

    func getMyProfile() async throws -> Profile {
        try await api.request("profile/info")
    }

    func getSocial(id: Int) async throws -> Profile {
        try await api.request("profile/social/\(id)")
    }

    func processProfile(id: Int) async throws -> Profile {
        try await api.request("profile/process/\(id)", method: "POST")
    }

    func getLoginHistory(id: Int, page: Int) async throws -> PaginatedResponse<HistoryItem> {
        try await api.request("profile/login/history/all/\(id)/\(page)")
    }
}

struct FeedAPI {
    private let api = APIClient.shared

    func getAll(page: Int) async throws -> PaginatedResponse<ArticleCompact> {
        try await api.request("feed/all/\(page)")
    }

    func getLatest() async throws -> [ReleaseCompact] {
        try await api.request("feed/latest")
    }

    func getLatestAll(page: Int) async throws -> PaginatedResponse<ReleaseCompact> {
        try await api.request("feed/latest/all/\(page)")
    }
}

struct SearchAPI {
    private let api = APIClient.shared

    func searchReleases(page: Int, query: String) async throws -> PaginatedResponse<ReleaseCompact> {
        try await api.request("search/releases/\(page)", method: "POST",
            body: JSONObject(dictionary: ["query": query]))
    }

    func searchCollections(page: Int, query: String) async throws -> PaginatedResponse<CollectionCompact> {
        try await api.request("search/collections/\(page)", method: "POST",
            body: JSONObject(dictionary: ["query": query]))
    }

    func searchProfiles(page: Int, query: String) async throws -> PaginatedResponse<ProfileSlim> {
        try await api.request("search/profiles/\(page)", method: "POST",
            body: JSONObject(dictionary: ["query": query]))
    }

    func searchChannels(page: Int, query: String) async throws -> PaginatedResponse<ChannelCompact> {
        try await api.request("search/channels/\(page)", method: "POST",
            body: JSONObject(dictionary: ["query": query]))
    }

    func searchArticles(page: Int, query: String) async throws -> PaginatedResponse<ArticleCompact> {
        try await api.request("search/articles/\(page)", method: "POST",
            body: JSONObject(dictionary: ["query": query]))
    }
}

struct DiscoverAPI {
    private let api = APIClient.shared

    func getInteresting() async throws -> [ReleaseCompact] {
        try await api.request("discover/interesting", method: "POST")
    }

    func getRecommendations(page: Int) async throws -> PaginatedResponse<ReleaseCompact> {
        try await api.request("discover/recommendations/\(page)", method: "POST")
    }

    func getWatching(page: Int) async throws -> PaginatedResponse<ReleaseCompact> {
        try await api.request("discover/watching/\(page)", method: "POST")
    }

    func getDiscussing() async throws -> [ReleaseCompact] {
        try await api.request("discover/discussing", method: "POST")
    }

    func getComments() async throws -> [CommentWeek] {
        try await api.request("discover/comments", method: "POST")
    }
}

struct CollectionAPI {
    private let api = APIClient.shared

    func getCollection(id: Int) async throws -> Collection {
        try await api.request("collection/\(id)")
    }

    func getAll(page: Int) async throws -> PaginatedResponse<Collection> {
        try await api.request("collection/all/\(page)")
    }

    func getReleases(id: Int, page: Int) async throws -> PaginatedResponse<ReleaseCompact> {
        try await api.request("collection/\(id)/releases/\(page)")
    }
}

struct FavoriteAPI {
    private let api = APIClient.shared

    func getAll(page: Int) async throws -> FavoritesResponse {
        try await api.request("favorite/all/\(page)")
    }

    func add(releaseId: Int) async throws -> FavoritesResponse {
        try await api.request("favorite/add/\(releaseId)")
    }

    func delete(releaseId: Int) async throws -> FavoritesResponse {
        try await api.request("favorite/delete/\(releaseId)")
    }
}

struct HistoryAPI {
    private let api = APIClient.shared

    func getAll(page: Int) async throws -> HistoryResponse {
        try await api.request("history/\(page)")
    }

    func add(releaseId: Int, sourceId: Int, position: Int) async throws -> HistoryResponse {
        try await api.request("history/add/\(releaseId)/\(sourceId)/\(position)")
    }

    func delete(releaseId: Int) async throws -> HistoryResponse {
        try await api.request("history/delete/\(releaseId)")
    }
}

struct NotificationAPI {
    private let api = APIClient.shared

    func getCount() async throws -> NotificationCountResponse {
        try await api.request("notification/count")
    }

    func getAll(page: Int) async throws -> PaginatedResponse<NotificationItem> {
        try await api.request("notification/all/\(page)")
    }

    func markRead() async throws -> NotificationCountResponse {
        try await api.request("notification/read")
    }

    func deleteAll() async throws -> NotificationCountResponse {
        try await api.request("notification/delete/all")
    }
}

struct ChannelAPI {
    private let api = APIClient.shared

    func getChannel(id: Int) async throws -> Channel {
        try await api.request("channel/\(id)")
    }

    func getAll(page: Int) async throws -> PaginatedResponse<Channel> {
        try await api.request("channel/all/\(page)", method: "POST")
    }

    func subscribe(id: Int) async throws -> Channel {
        try await api.request("channel/subscribe/\(id)", method: "POST")
    }

    func unsubscribe(id: Int) async throws -> Channel {
        try await api.request("channel/unsubscribe/\(id)", method: "POST")
    }

    func getArticles(id: Int, page: Int) async throws -> PaginatedResponse<Article> {
        try await api.request("channel/\(id)/article/all/\(page)", method: "POST")
    }
}

struct ArticleAPI {
    private let api = APIClient.shared

    func getArticle(id: Int) async throws -> Article {
        try await api.request("article/\(id)")
    }

    func vote(articleId: Int, vote: Int) async throws -> Article {
        try await api.request("article/vote/\(articleId)/\(vote)")
    }
}

struct ScheduleAPI {
    private let api = APIClient.shared

    func getSchedule() async throws -> [String: [ReleaseCompact]] {
        try await api.request("schedule")
    }
}

struct TypeAPI {
    private let api = APIClient.shared

    func getAll() async throws -> [TypeItem] {
        try await api.request("type/all")
    }
}
