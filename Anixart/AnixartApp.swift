import SwiftUI

@main
struct AnixartApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .preferredColorScheme(authManager.isDarkMode ? .dark : nil)
                .onAppear {
                    Task {
                        try? await DDoSSolver.shared.initialize()
                        try? await loadConfig()
                    }
                }
        }
    }

    private func loadConfig() async {
        do {
            let config = try await APIClient.shared.getConfig()
            let token = await APIClient.shared.token
            let msg = "apiUrl=\(config.apiUrl ?? "nil"), apiAltUrl=\(config.apiAltUrl ?? "nil"), altConnectionMode=\(config.altConnectionMode ?? false)"
            print("[Config] loaded: \(msg)")
            await APILogger.shared.log(method: "CONFIG", url: "config/toggles", status: 200, response: msg)
            if let altUrl = config.apiAltUrl, !altUrl.isEmpty {
                await APILogger.shared.log(method: "CONFIG", url: "switch baseURL", status: 200, response: altUrl)
                await APIClient.shared.configure(baseURL: altUrl, token: token, altMode: true)
            } else if let apiUrl = config.apiUrl, !apiUrl.isEmpty {
                await APILogger.shared.log(method: "CONFIG", url: "switch baseURL", status: 200, response: apiUrl)
                await APIClient.shared.configure(baseURL: apiUrl, token: token, altMode: false)
            }
        } catch {
            print("[Config] error: \(error)")
            await APILogger.shared.log(method: "CONFIG", url: "config/toggles", status: -1, error: error.localizedDescription)
        }
    }
}
