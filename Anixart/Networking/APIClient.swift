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

    let appVersionCode = 26063014
    let appIsBeta = true

    private let userAgent = "Anixart/9.0 (Linux; Android 14; Pixel 9 Pro) Mobile"
    private let apiVersion = "v2"

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.httpCookieAcceptPolicy = .always
        session = URLSession(configuration: config)
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
    }

    private func encodeFormBody(_ body: Encodable) throws -> Data {
        guard let dict = body as? FormEncodable else { return Data() }
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&=")
        let items = dict.formValues.map { key, value in
            "\(key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key)=\(value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value)"
        }
        return items.joined(separator: "&").data(using: .utf8) ?? Data()
    }

    private func encodeJSONBody(_ body: Encodable) throws -> Data {
        return try JSONEncoder().encode(body)
    }

    func configure(
        baseURL: String,
        token: String?,
        altMode: Bool = false
    ) async {
        _baseURL = baseURL
        _token = token
        _altConnectionMode = altMode
    }

    func setToken(_ token: String?) async {
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
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(apiVersion, forHTTPHeaderField: "API-Version")

        if let body {
            if body is FormEncodable {
                let formBody = try encodeFormBody(body)
                request.httpBody = formBody
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            } else {
                let jsonBody = try encodeJSONBody(body)
                request.httpBody = jsonBody
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        let bodyString = body != nil ? (String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "") : ""
        print("[API] \(method) \(url)")

        do {
            let (data, response) = try await session.data(for: request)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            let responseString = String(data: data, encoding: .utf8) ?? ""
            print("[API] \(method) \(url) -> \(status) \(data.count) bytes")
            await APILogger.shared.log(method: method, url: url.absoluteString, status: status, body: bodyString, response: responseString)
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
            await APILogger.shared.log(method: method, url: url.absoluteString, status: -1, body: bodyString, error: error.localizedDescription)
            throw error
        } catch let error as DecodingError {
            await APILogger.shared.log(method: method, url: url.absoluteString, status: -2, body: bodyString, error: error.localizedDescription)
            throw APIError.decodingError(error)
        } catch {
            await APILogger.shared.log(method: method, url: url.absoluteString, status: -3, body: bodyString, error: error.localizedDescription)
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
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.setValue(apiVersion, forHTTPHeaderField: "API-Version")

        if let body {
            if body is FormEncodable {
                let formBody = try encodeFormBody(body)
                request.httpBody = formBody
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            } else {
                let jsonBody = try encodeJSONBody(body)
                request.httpBody = jsonBody
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }

        let bodyString = body != nil ? (String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "") : ""
        print("[API] \(method) \(url)")

        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        let responseString = String(data: data, encoding: .utf8) ?? ""
        print("[API] \(method) \(url) -> \(status) \(data.count) bytes")
        await APILogger.shared.log(method: method, url: url.absoluteString, status: status, body: bodyString, response: responseString)
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
        try await request(
            "config/toggles",
            queryItems: [
                URLQueryItem(name: "version_code", value: "\(appVersionCode)"),
                URLQueryItem(name: "is_beta", value: appIsBeta ? "true" : "false"),
                URLQueryItem(name: "is_api_alt", value: altConnectionMode ? "true" : "false")
            ]
        )
    }

    func getUrls() async throws -> ConfigUrlsResponse {
        try await request(
            "config/urls",
            queryItems: [
                URLQueryItem(name: "version_code", value: "\(appVersionCode)"),
                URLQueryItem(name: "is_beta", value: appIsBeta ? "true" : "false")
            ]
        )
    }
}

struct ErrorResponse: Codable {
    let message: String?
}
