import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated = false
    @Published var currentProfile: Profile?
    @Published var token: String?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isDarkMode = true

    private let api = APIClient.shared
    private let defaults = UserDefaults.standard
    private var verifyHash: String = ""

    private init() {
        loadSavedSession()
    }

    private func loadSavedSession() {
        if let token = defaults.string(forKey: "auth_token"),
           let profileData = defaults.data(forKey: "profile"),
           let profile = try? JSONDecoder().decode(Profile.self, from: profileData) {
            self.token = token
            self.currentProfile = profile
            self.isAuthenticated = true
            Task { await api.setToken(token) }
        }
        isDarkMode = defaults.bool(forKey: "dark_mode") != false
    }

    func signIn(login: String, password: String) async {
        isLoading = true
        error = nil
        do {
            let body = ["login": login, "password": password]
            let response: SignInResponse = try await api.request("auth/signIn", method: "POST",
                body: JSONObject(dictionary: body))
            if let token = response.profileToken?.token {
                saveSession(token: token, profile: response.profile)
            } else if response.code == 3 {
                error = "Неверный логин или пароль"
            } else {
                error = "Ошибка входа (код \(response.code ?? -1))"
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signUp(login: String, email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            let body = ["login": login, "email": email, "password": password]
            let response: SignUpResponse = try await api.request("auth/signUp", method: "POST",
                body: JSONObject(dictionary: body))
            verifyHash = response.hash ?? ""
            if response.code == 0 || response.code == 9 {
                error = "Код подтверждения отправлен на email"
            } else {
                error = "Ошибка регистрации (код \(response.code ?? -1))"
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func verify(code: String) async {
        isLoading = true
        error = nil
        do {
            var params: [String: String] = ["code": code]
            if !verifyHash.isEmpty { params["hash"] = verifyHash }

            // Try POST first
            var data: Data
            do {
                data = try await api.requestData("auth/verify", method: "POST",
                    body: JSONObject(dictionary: params))
            } catch {
                // Try GET if POST fails
                data = try await api.requestData("auth/verify?code=\(code)" + (verifyHash.isEmpty ? "" : "&hash=\(verifyHash)"),
                    method: "GET")
            }

            let raw = String(data: data, encoding: .utf8) ?? "nil"
            print("[verify] raw: \(raw)")

            if data.isEmpty {
                error = "Сервер вернул пустой ответ. Попробуйте позже."
                isLoading = false; return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let t = json["token"] as? String {
                    saveSession(token: t, profile: nil); isLoading = false; return
                }
                if let pt = json["profileToken"] as? [String: Any], let t = pt["token"] as? String {
                    saveSession(token: t, profile: nil); isLoading = false; return
                }
                error = "API: \(json)"
                isLoading = false; return
            }
            error = "Неизвестный формат ответа: \(raw.prefix(200))"
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

struct VerifyTokenResponse: Codable {
    let token: String?
}
struct VerifyErrorResponse: Codable {
    let message: String?
    let error: String?
}

    func signInWithGoogle(presenting viewController: UIViewController) async {
        isLoading = true
        error = nil
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            guard let idToken = result.user.idToken?.tokenString else {
                error = "Не удалось получить токен Google"
                isLoading = false
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: result.user.accessToken.tokenString)
            let authResult = try await Auth.auth().signIn(with: credential)
            let firebaseToken = try await authResult.user.getIDToken()
            let response: GoogleResponse = try await api.request("auth/google", method: "POST",
                body: JSONObject(dictionary: ["firebaseToken": firebaseToken]))
            if let token = response.profileToken?.token {
                saveSession(token: token, profile: response.profileToken?.profile)
            } else {
                error = "Ошибка входа через Google (код \(response.code ?? -1))"
            }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func signInWithTelegram() async {
        // Telegram auth is handled via a WebView/ASWebAuthenticationSession
        // Opens tg://resolve?domain=anixart_tv_bot&start=auth
        isLoading = false
    }

    func signInWithVK() async {
        // VK auth would use VK SDK or WebView
        isLoading = false
    }

    func restore(login: String) async {
        isLoading = true
        error = nil
        do {
            let response: RestoreResponse = try await api.request("auth/restore", method: "POST",
                body: JSONObject(dictionary: ["login": login]))
            error = response.message ?? "Код восстановления отправлен на email (код \(response.code ?? -1))"
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func logout() {
        token = nil
        currentProfile = nil
        isAuthenticated = false
        Task { await api.setToken(nil) }
        defaults.removeObject(forKey: "auth_token")
        defaults.removeObject(forKey: "profile")
    }

    private func saveSession(token: String, profile: Profile?) {
        self.token = token
        self.currentProfile = profile
        self.isAuthenticated = true
        Task { await api.setToken(token) }
        defaults.set(token, forKey: "auth_token")
        if let profile {
            if let data = try? JSONEncoder().encode(profile) {
                defaults.set(data, forKey: "profile")
            }
        }
    }

    func toggleDarkMode() {
        isDarkMode.toggle()
        defaults.set(isDarkMode, forKey: "dark_mode")
    }

    func fetchProfile() async {
        do {
            let profile: Profile = try await api.request("profile/info")
            currentProfile = profile
            if let data = try? JSONEncoder().encode(profile) {
                defaults.set(data, forKey: "profile")
            }
        } catch {
            if let apiError = error as? APIError, case .unauthorized = apiError {
                logout()
            }
        }
    }
}

protocol FormEncodable {
    var formValues: [String: String] { get }
}

struct JSONObject: FormEncodable, Encodable {
    let dictionary: [String: String]
    var formValues: [String: String] { dictionary }
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DynamicKey.self)
        for (key, value) in dictionary {
            try container.encode(value, forKey: DynamicKey(stringValue: key)!)
        }
    }
}

struct SignInResponse: Codable {
    let code: Int?
    let profile: Profile?
    let profileToken: ProfileToken?
}

struct SignUpResponse: Codable {
    let code: Int?
    let hash: String?
    let codeTimestampExpires: Int?
}

struct VerifyResponse: Codable {
    let code: Int?
    let token: String?
    let profileToken: ProfileToken?
    let message: String?
}

struct RestoreResponse: Codable {
    let code: Int?
    let message: String?
}

struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { self.intValue = intValue; stringValue = "\(intValue)" }
}
