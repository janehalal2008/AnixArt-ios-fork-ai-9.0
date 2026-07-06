import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        if ProcessInfo.processInfo.arguments.contains("-debug") {
            NavigationStack {
                DebugView()
            }
        } else if authManager.isAuthenticated {
            MainTabView()
        } else {
            AuthView()
        }
    }
}
