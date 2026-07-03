import Foundation

struct Episode: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let position: Int
    let sources: [Source]?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Episode, rhs: Episode) -> Bool {
        lhs.id == rhs.id
    }
}

struct EpisodeCompact: Codable, Identifiable {
    let id: Int
    let name: String
    let position: Int
}

struct Source: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let hosting: String?
    let url: String?
    let quality: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Source, rhs: Source) -> Bool {
        lhs.id == rhs.id
    }
}

struct EpisodeResponse: Codable {
    let types: [TypeItem]?
    let sources: [Source]?
    let typeCurrent: TypeItem?
    let episodes: [Episode]?
    let message: String?
}

struct EpisodeTargetResponse: Codable {
    let source: Source?
    let message: String?
}

struct EpisodeUpdate: Codable, Identifiable {
    let id: Int
    let releaseId: Int?
    let releaseName: String?
    let poster: Release.Poster?
    let episodePosition: Int?
    let episodeName: String?
    let createdAt: String?
}
