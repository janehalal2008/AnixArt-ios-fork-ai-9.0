import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    private let tabs = [
        (title: "Главная", icon: "house.fill", index: 0),
        (title: "Каталог", icon: "square.grid.2x2.fill", index: 1),
        (title: "Обзор", icon: "sparkles", index: 2),
        (title: "Поиск", icon: "magnifyingglass", index: 3),
        (title: "Профиль", icon: "person.fill", index: 4)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            AnixartColor.background.ignoresSafeArea()

            switch selectedTab {
            case 0: HomeView()
            case 1: CatalogView()
            case 2: DiscoverView()
            case 3: SearchView()
            case 4: ProfileMenuView()
            default: HomeView()
            }

            VStack(spacing: 0) {
                Divider().background(AnixartColor.divider)
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.index) { tab in
                        Button {
                            selectedTab = tab.index
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 22, weight: selectedTab == tab.index ? .semibold : .regular))
                                    .frame(height: 24)
                                Text(tab.title)
                                    .font(AnixartFont.small)
                            }
                            .foregroundColor(selectedTab == tab.index ? AnixartColor.accent : AnixartColor.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                    }
                }
                .background(AnixartColor.surface)
            }
        }
    }
}
