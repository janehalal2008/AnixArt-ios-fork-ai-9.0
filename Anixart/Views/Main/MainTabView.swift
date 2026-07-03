import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Главная", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            CatalogView()
                .tabItem {
                    Label("Каталог", systemImage: selectedTab == 1 ? "square.grid.2x2.fill" : "square.grid.2x2")
                }
                .tag(1)

            DiscoverView()
                .tabItem {
                    Label("Обзор", systemImage: selectedTab == 2 ? "sparkles.fill" : "sparkles")
                }
                .tag(2)

            SearchView()
                .tabItem {
                    Label("Поиск", systemImage: selectedTab == 3 ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                }
                .tag(3)

            ProfileMenuView()
                .tabItem {
                    Label("Профиль", systemImage: selectedTab == 4 ? "person.fill" : "person")
                }
                .tag(4)
        }
        .tint(.accentColor)
    }
}
