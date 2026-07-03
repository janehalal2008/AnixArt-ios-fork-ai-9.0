import Foundation

struct EpisodeAPI {
    private let api = APIClient.shared

    func getEpisodes(releaseId: Int) async throws -> EpisodeResponse {
        try await api.request("episode/\(releaseId)")
    }

    func getEpisodes(releaseId: Int, typeId: Int) async throws -> EpisodeResponse {
        try await api.request("episode/\(releaseId)/\(typeId)")
    }

    func getEpisodes(releaseId: Int, typeId: Int, sourceId: Int) async throws -> EpisodeResponse {
        try await api.request("episode/\(releaseId)/\(typeId)/\(sourceId)")
    }

    func getTargetEpisode(releaseId: Int, sourceId: Int, position: Int) async throws -> EpisodeTargetResponse {
        try await api.request("episode/target/\(releaseId)/\(sourceId)/\(position)")
    }

    func watch(releaseId: Int, sourceId: Int) async throws -> EpisodeResponse {
        try await api.request("episode/watch/\(releaseId)/\(sourceId)", method: "POST")
    }

    func watch(releaseId: Int, sourceId: Int, position: Int) async throws -> EpisodeResponse {
        try await api.request("episode/watch/\(releaseId)/\(sourceId)/\(position)", method: "POST")
    }

    func unwatch(releaseId: Int, sourceId: Int) async throws -> EpisodeResponse {
        try await api.request("episode/unwatch/\(releaseId)/\(sourceId)", method: "POST")
    }

    func getUpdates(releaseId: Int, page: Int) async throws -> PaginatedResponse<EpisodeUpdate> {
        try await api.request("episode/updates/\(releaseId)/\(page)")
    }
}
