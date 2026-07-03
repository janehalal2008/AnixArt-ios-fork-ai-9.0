import Foundation

struct Collection: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let image: String?
    let imageBig: String?
    let profile: ProfileSlim?
    let releasesCount: Int?
    let subscribersCount: Int?
    let isSubscribed: Bool?
    let isFavorite: Bool?
    let createdAt: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Collection, rhs: Collection) -> Bool {
        lhs.id == rhs.id
    }
}

struct CollectionCompact: Codable, Identifiable {
    let id: Int
    let name: String
    let image: String?
    let profile: ProfileSlim?
}
