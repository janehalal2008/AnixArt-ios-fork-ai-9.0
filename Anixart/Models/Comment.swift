import Foundation

struct Comment: Codable, Identifiable, Hashable {
    let id: Int
    let text: String?
    let profile: ProfileSlim?
    let releaseId: Int?
    let collectionId: Int?
    let articleId: Int?
    let parentId: Int?
    let children: [Comment]?
    let vote: Int?
    let voteUp: Int?
    let voteDown: Int?
    let canEdit: Bool?
    let canDelete: Bool?
    let createdAt: String?
    let updatedAt: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}

struct CommentCompact: Codable, Identifiable {
    let id: Int
    let text: String?
    let profile: ProfileSlim?
    let createdAt: String?
}

struct CommentWeek: Codable, Identifiable {
    let id: Int
    let text: String?
    let profile: ProfileSlim?
    let releaseId: Int?
    let releaseName: String?
    let voteUp: Int?
    let createdAt: String?
}
