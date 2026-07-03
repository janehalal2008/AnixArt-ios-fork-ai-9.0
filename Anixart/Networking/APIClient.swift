import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case unauthorized
    case serverError(String)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Неверный URL"
        case .noData: return "Нет данных"
        case .unauthorized: return "Требуется авторизация"
        case .serverError(let msg): return msg
        case .decodingError(let err): return "Ошибка обработки данных: \(err.localizedDescription)"
        case .networkError(let err): return "Ошибка сети: \(err.localizedDescription)"
        }
    }
}

actor APIClient {
    static let shared = APIClient()
    private let session: URLSession
    private let decoder: JSONDecoder

    private var _baseURL = "https://api-s.anixsekai.com/"
    private var _token: String?
    private var _altConnectionMode = false

    var baseURL: String { _baseURL }
    var token: String? { _token }
    var altConnectionMode: Bool { _altConnectionMode }

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
    }

    func configure(
        baseURL: String,
        token: String?,
        altMode: Bool = false
    ) {
        _baseURL = baseURL
        _token = token
        _altConnectionMode = altMode
    }

    func setToken(_ token: String?) {
        _token = token
    }

    func request<T: Decodable>(
        _ path: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil,
        useToken: Bool = true
    ) async throws -> T {
        guard var components = URLComponents(string: _baseURL + path) else {
            throw APIError.invalidURL
        }

        var allQueryItems = queryItems ?? []
        if useToken, let token = _token {
            allQueryItems.append(URLQueryItem(name: "token", value: token))
        }
        if !allQueryItems.isEmpty {
            components.queryItems = allQueryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Anixart/9.0 (iOS; iPhone; iOS 17.0)", forHTTPHeaderField: "User-Agent")

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError("Invalid response")
            }

            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }

            if httpResponse.statusCode >= 400 {
                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.message ?? "Unknown error")
                }
                throw APIError.serverError("HTTP \(httpResponse.statusCode)")
            }

            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }

    func requestData(
        _ path: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Encodable? = nil,
        useToken: Bool = true
    ) async throws -> Data {
        guard var components = URLComponents(string: _baseURL + path) else {
            throw APIError.invalidURL
        }

        var allQueryItems = queryItems ?? []
        if useToken, let token = _token {
            allQueryItems.append(URLQueryItem(name: "token", value: token))
        }
        if !allQueryItems.isEmpty {
            components.queryItems = allQueryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Anixart/9.0 (iOS; iPhone; iOS 17.0)", forHTTPHeaderField: "User-Agent")

        if let body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError("Invalid response")
        }

        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }

        if httpResponse.statusCode >= 400 {
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.message ?? "Unknown error")
            }
            throw APIError.serverError("HTTP \(httpResponse.statusCode)")
        }

        return data
    }

    func getConfig() async throws -> TogglesResponse {
        try await request("config/toggles")
    }

    func getUrls() async throws -> ConfigUrlsResponse {
        try await request("config/urls")
    }
}

struct ErrorResponse: Codable {
    let message: String?
}
