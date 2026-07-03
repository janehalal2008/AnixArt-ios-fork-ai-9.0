import SwiftUI

struct ProfileMenuView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: ProfileView(profileId: authManager.currentProfile?.id ?? 0)) {
                        HStack {
                            CachedImage(url: authManager.currentProfile?.avatar)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            VStack(alignment: .leading) {
                                Text(authManager.currentProfile?.login ?? "Профиль")
                                    .font(.headline)
                                Text(authManager.currentProfile?.role?.rawValue ?? "")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Моё") {
                    NavigationLink(destination: FavoritesView()) {
                        Label("Избранное", systemImage: "heart")
                    }
                    NavigationLink(destination: HistoryView()) {
                        Label("История", systemImage: "clock")
                    }
                    NavigationLink(destination: NotificationsView()) {
                        Label("Уведомления", systemImage: "bell")
                    }
                    NavigationLink(destination: CollectionsListView()) {
                        Label("Коллекции", systemImage: "folder")
                    }
                    NavigationLink(destination: SubscriptionsView()) {
                        Label("Подписки", systemImage: "person.2")
                    }
                }

                Section("Настройки") {
                    Toggle(isOn: $authManager.isDarkMode) {
                        Label("Тёмная тема", systemImage: "moon")
                    }
                    .onChange(of: authManager.isDarkMode) { _, _ in
                        authManager.toggleDarkMode()
                    }
                }

                Section {
                    Button(role: .destructive) {
                        authManager.logout()
                    } label: {
                        Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Профиль")
            .task {
                if authManager.isAuthenticated {
                    await authManager.fetchProfile()
                }
            }
        }
    }
}

struct FavoritesView: View {
    @State private var favorites: [Favorite] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                List(favorites) { fav in
                    if let release = fav.release {
                        NavigationLink(value: release) {
                            SearchReleaseRow(release: release)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: ReleaseCompact.self) { release in
                    ReleaseDetailView(releaseId: release.id)
                }
            }
        }
        .navigationTitle("Избранное")
        .task {
            do {
                let result = try await FavoriteAPI().getAll(page: 1)
                favorites = result.favorites ?? []
            } catch {}
            isLoading = false
        }
    }
}

struct HistoryView: View {
    @State private var history: [HistoryItem] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if history.isEmpty {
                ContentUnavailableView("История пуста", systemImage: "clock", description: Text("Вы ещё не смотрели аниме"))
            } else {
                List(history) { item in
                    NavigationLink(value: ReleaseCompact(
                        id: item.releaseId ?? 0,
                        name: item.releaseName ?? "",
                        poster: item.poster,
                        year: nil, rating: nil, status: nil,
                        episodesTotal: nil, episodes: nil, types: nil
                    )) {
                        HStack {
                            CachedImage(url: item.poster?.preview)
                                .frame(width: 48, height: 68)
                                .cornerRadius(6)
                            VStack(alignment: .leading) {
                                Text(item.releaseName ?? "")
                                    .font(.subheadline).fontWeight(.semibold)
                                Text("Серия \(item.episodeName ?? "")")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .navigationDestination(for: ReleaseCompact.self) { release in
                    ReleaseDetailView(releaseId: release.id)
                }
            }
        }
        .navigationTitle("История")
        .task {
            do {
                let result = try await HistoryAPI().getAll(page: 1)
                history = result.history ?? []
            } catch {}
            isLoading = false
        }
    }
}

struct SubscriptionsView: View {
    @State private var channels: [Channel] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                List(channels) { channel in
                    NavigationLink(destination: ChannelDetailView(channelId: channel.id)) {
                        HStack {
                            CachedImage(url: channel.avatar)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            Text(channel.name ?? "")
                                .font(.subheadline)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Подписки")
        .task {
            do {
                channels = try await ChannelAPI().getAll(page: 1).items ?? []
            } catch {}
            isLoading = false
        }
    }
}

struct CollectionsListView: View {
    @State private var collections: [Collection] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                List(collections) { collection in
                    NavigationLink(destination: CollectionDetailView(collectionId: collection.id)) {
                        HStack {
                            CachedImage(url: collection.image)
                                .frame(width: 48, height: 48)
                                .cornerRadius(8)
                            VStack(alignment: .leading) {
                                Text(collection.name)
                                    .font(.subheadline).fontWeight(.semibold)
                                Text("\(collection.releasesCount ?? 0) релизов")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Коллекции")
        .task {
            do {
                collections = try await CollectionAPI().getAll(page: 1).items ?? []
            } catch {}
            isLoading = false
        }
    }
}
