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
            print("[Config] loaded: apiUrl=\(config.apiUrl ?? "nil"), apiAltUrl=\(config.apiAltUrl ?? "nil")")
            if let altUrl = config.apiAltUrl, !altUrl.isEmpty {
                await APIClient.shared.configure(baseURL: altUrl, token: token, altMode: true)
            } else if let apiUrl = config.apiUrl, !apiUrl.isEmpty {
                await APIClient.shared.configure(baseURL: apiUrl, token: token, altMode: false)
            }
        } catch {
            print("[Config] error: \(error)")
        }
    }
}
