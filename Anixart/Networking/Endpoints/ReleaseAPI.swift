import Foundation

struct ReleaseAPI {
    private let api = APIClient.shared

    func getRelease(id: Int) async throws -> ReleaseResponse {
        try await api.request("release/\(id)")
    }

    func getRandom() async throws -> Release {
        try await api.request("release/random")
    }

    func getRandomFavorite() async throws -> Release {
        try await api.request("release/random/favorite")
    }

    func getRandomFromCollection(id: Int) async throws -> Release {
        try await api.request("release/collection/\(id)/random")
    }

    func vote(releaseId: Int, vote: Int) async throws -> ReleaseResponse {
        try await api.request("release/vote/add/\(releaseId)/\(vote)")
    }

    func deleteVote(releaseId: Int) async throws -> ReleaseResponse {
        try await api.request("release/vote/delete/\(releaseId)")
    }

    func search(page: Int, query: String? = nil, genres: [Int]? = nil,
                status: String? = nil, year: Int? = nil, type: Int? = nil,
                season: String? = nil, sort: String? = nil) async throws -> PaginatedResponse<ReleaseCompact> {
        var body: [String: Any] = [:]
        if let query { body["query"] = query }
        if let genres { body["genres"] = genres }
        if let status { body["status"] = status }
        if let year { body["year"] = year }
        if let type { body["type"] = type }
        if let season { body["season"] = season }
        if let sort { body["sort"] = sort }
        let data = try await api.requestData("filter/\(page)", method: "POST",
            body: AnyJSONObject(dictionary: body))
        return try JSONDecoder().decode(PaginatedResponse<ReleaseCompact>.self, from: data)
    }
}

struct AnyJSONObject: FormEncodable, Encodable {
    let dictionary: [String: Any]
    var formValues: [String: String] {
        var result: [String: String] = [:]
        for (key, value) in dictionary {
            if let v = value as? String { result[key] = v }
            else if let v = value as? Int { result[key] = String(v) }
            else if let v = value as? Bool { result[key] = v ? "1" : "0" }
        }
        return result
    }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        for (key, value) in dictionary {
            if let v = value as? String { try container.encode(v, forKey: DynamicKey(stringValue: key)!) }
            else if let v = value as? Int { try container.encode(v, forKey: DynamicKey(stringValue: key)!) }
            else if let v = value as? [Int] { try container.encode(v, forKey: DynamicKey(stringValue: key)!) }
            else if let v = value as? Bool { try container.encode(v, forKey: DynamicKey(stringValue: key)!) }
        }
    }
}
