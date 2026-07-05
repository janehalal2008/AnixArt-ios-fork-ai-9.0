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
                .task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    try? await DDoSSolver.shared.initialize()
                }
        }
    }
}
