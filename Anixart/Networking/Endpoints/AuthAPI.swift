import Foundation

struct AuthAPI {
    private let api = APIClient.shared

    func signIn(login: String, password: String) async throws -> SignInResponse {
        try await api.request("auth/signIn", method: "POST",
            body: JSONObject(dictionary: ["login": login, "password": password]))
    }

    func signUp(login: String, email: String, password: String) async throws -> SignUpResponse {
        try await api.request("auth/signUp", method: "POST",
            body: JSONObject(dictionary: ["login": login, "email": email, "password": password]))
    }

    func checkLogin(login: String) async throws -> CheckLoginResponse {
        try await api.request("auth/checkLogin", method: "POST",
            body: JSONObject(dictionary: ["login": login]))
    }

    func verify(code: String) async throws -> VerifyResponse {
        try await api.request("auth/verify", method: "POST",
            body: JSONObject(dictionary: ["code": code]))
    }

    func resend() async throws -> VerifyResponse {
        try await api.request("auth/resend", method: "POST", body: JSONObject(dictionary: [:]))
    }

    func restore(login: String) async throws -> VerifyResponse {
        try await api.request("auth/restore", method: "POST",
            body: JSONObject(dictionary: ["login": login]))
    }

    func restoreVerify(code: String) async throws -> VerifyResponse {
        try await api.request("auth/restore/verify", method: "POST",
            body: JSONObject(dictionary: ["code": code]))
    }
}
