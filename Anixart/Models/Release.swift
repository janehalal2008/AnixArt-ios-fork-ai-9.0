import Foundation

struct Release: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let poster: Poster?
    let description: String?
    let episodes: Int?
    let episodesTotal: Int?
    let season: Season?
    let year: Int?
    let status: ReleaseStatus?
    let rating: Double?
    let votes: Votes?
    let genres: [Genre]?
    let types: [TypeItem]?
    let favoriteStatus: String?
    let inFavorites: Bool?
    let lastWatchedEpisode: String?
    let lastWatchedEpisodePosition: Int?
    let episodesWatchCount: Int?

    struct Poster: Codable, Hashable {
        let preview: String?
        let `default`: String?
        let big: String?
    }

    struct Season: Codable, Hashable {
        let id: Int?
        let name: String?
        let year: Int?
    }

    struct Votes: Codable, Hashable {
        let up: Int?
        let down: Int?
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Release, rhs: Release) -> Bool {
        lhs.id == rhs.id
    }
}

struct ReleaseCompact: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let poster: Release.Poster?
    let year: Int?
    let rating: Double?
    let status: ReleaseStatus?
    let episodesTotal: Int?
    let episodes: Int?
    let types: [TypeItem]?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ReleaseCompact, rhs: ReleaseCompact) -> Bool {
        lhs.id == rhs.id
    }
}

enum ReleaseStatus: String, Codable, CaseIterable {
    case ongoing = "ONGOING"
    case completed = "COMPLETED"
    case announced = "ANNOUNCED"
    case paused = "PAUSED"

    var displayName: String {
        switch self {
        case .ongoing: return "Онгоинг"
        case .completed: return "Завершён"
        case .announced: return "Анонс"
        case .paused: return "Заморожен"
        }
    }
}

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let image: String?
}

struct TypeItem: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let shortName: String?
}

struct ReleaseResponse: Codable {
    let release: Release?
    let message: String?
}
