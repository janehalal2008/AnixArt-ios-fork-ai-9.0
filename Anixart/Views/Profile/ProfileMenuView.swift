import SwiftUI

struct ProfileMenuView: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ZStack {
                AnixartColor.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        NavigationLink(value: authManager.currentProfile?.id ?? 0) {
                            HStack(spacing: 16) {
                                CachedImage(url: authManager.currentProfile?.avatar)
                                    .frame(width: 70, height: 70)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(AnixartColor.accent, lineWidth: 2))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(authManager.currentProfile?.login ?? "Профиль")
                                        .font(AnixartFont.headline)
                                        .foregroundColor(AnixartColor.textPrimary)
                                    Text(authManager.currentProfile?.role?.rawValue ?? "")
                                        .font(AnixartFont.caption)
                                        .foregroundColor(AnixartColor.textSecondary)
                                }

                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AnixartColor.textSecondary)
                            }
                            .padding()
                            .background(AnixartColor.surface)
                            .cornerRadius(16)
                        }
                        .buttonStyle(PlainButtonStyle())

                        VStack(spacing: 0) {
                            menuRow(icon: "heart.fill", iconColor: AnixartColor.accent, title: "Избранное", destination: FavoritesView())
                            menuRow(icon: "clock.fill", iconColor: AnixartColor.blue, title: "История", destination: HistoryView())
                            menuRow(icon: "bell.fill", iconColor: AnixartColor.yellow, title: "Уведомления", destination: NotificationsView())
                            menuRow(icon: "folder.fill", iconColor: AnixartColor.green, title: "Коллекции", destination: CollectionsListView())
                            menuRow(icon: "person.2.fill", iconColor: AnixartColor.accentPurple, title: "Подписки", destination: SubscriptionsView())
                        }
                        .background(AnixartColor.surface)
                        .cornerRadius(16)

                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "moon.fill")
                                    .foregroundColor(AnixartColor.accentPurple)
                                    .frame(width: 28)
                                Text("Тёмная тема")
                                    .font(AnixartFont.body)
                                    .foregroundColor(AnixartColor.textPrimary)
                                Spacer()
                                Toggle("", isOn: $authManager.isDarkMode)
                                    .tint(AnixartColor.accent)
                                    .labelsHidden()
                                    .onChange(of: authManager.isDarkMode) { _, _ in
                                        authManager.toggleDarkMode()
                                    }
                            }
                            .padding()
                        }
                        .background(AnixartColor.surface)
                        .cornerRadius(16)

                        NavigationLink(destination: DebugView()) {
                            HStack {
                                Image(systemName: "ant.fill")
                                    .foregroundColor(AnixartColor.textSecondary)
                                    .frame(width: 28)
                                Text("Debug")
                                    .font(AnixartFont.body)
                                    .foregroundColor(AnixartColor.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(AnixartColor.textSecondary)
                            }
                            .padding()
                            .background(AnixartColor.surface)
                            .cornerRadius(16)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button {
                            authManager.logout()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(AnixartColor.accent)
                                    .frame(width: 28)
                                Text("Выйти")
                                    .font(AnixartFont.body)
                                    .foregroundColor(AnixartColor.accent)
                                Spacer()
                            }
                            .padding()
                            .background(AnixartColor.surface)
                            .cornerRadius(16)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                    .padding(.bottom, 80)
                }
            }
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AnixartColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: Int.self) { profileId in
                ProfileView(profileId: profileId)
            }
            .task {
                if authManager.isAuthenticated {
                    await authManager.fetchProfile()
                }
            }
        }
    }

    private func menuRow<Destination: View>(icon: String, iconColor: Color, title: String, destination: Destination) -> some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .frame(width: 28)
                Text(title)
                    .font(AnixartFont.body)
                    .foregroundColor(AnixartColor.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(AnixartColor.textSecondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FavoritesView: View {
    @State private var favorites: [Favorite] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()
            Group {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
                } else {
                    List(favorites) { fav in
                        if let release = fav.release {
                            NavigationLink(value: release) {
                                AnixartListReleaseRow(release: release)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(AnixartColor.background)
                    .navigationDestination(for: ReleaseCompact.self) { release in
                        ReleaseDetailView(releaseId: release.id)
                    }
                }
            }
        }
        .navigationTitle("Избранное")
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            do {
                let result = try await FavoriteAPI().getAll(page: 1)
                favorites = result.favorites ?? []
            } catch {}
            isLoading = false
        }
    }
}

struct AnixartListReleaseRow: View {
    let release: ReleaseCompact

    var body: some View {
        HStack(spacing: 14) {
            CachedImage(url: release.poster?.preview)
                .frame(width: 60, height: 88)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(release.name)
                    .font(AnixartFont.body)
                    .fontWeight(.semibold)
                    .foregroundColor(AnixartColor.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AnixartColor.yellow)
                    Text(String(format: "%.1f", release.rating ?? 0))
                        .font(AnixartFont.small)
                        .foregroundColor(AnixartColor.textSecondary)
                }

                Text(release.status?.displayName ?? "")
                    .font(AnixartFont.small)
                    .foregroundColor(AnixartColor.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .background(AnixartColor.background)
    }
}

struct HistoryView: View {
    @State private var history: [HistoryItem] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()
            Group {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
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
                            HStack(spacing: 14) {
                                CachedImage(url: item.poster?.preview)
                                    .frame(width: 60, height: 88)
                                    .cornerRadius(12)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.releaseName ?? "")
                                        .font(AnixartFont.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AnixartColor.textPrimary)
                                    Text("Серия \(item.episodeName ?? "")")
                                        .font(AnixartFont.small)
                                        .foregroundColor(AnixartColor.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .background(AnixartColor.background)
                        }
                    }
                    .listStyle(.plain)
                    .background(AnixartColor.background)
                    .navigationDestination(for: ReleaseCompact.self) { release in
                        ReleaseDetailView(releaseId: release.id)
                    }
                }
            }
        }
        .navigationTitle("История")
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
        ZStack {
            AnixartColor.background.ignoresSafeArea()
            Group {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
                } else {
                    List(channels) { channel in
                        NavigationLink(destination: ChannelDetailView(channelId: channel.id)) {
                            HStack(spacing: 14) {
                                CachedImage(url: channel.avatar)
                                    .frame(width: 48, height: 48)
                                    .clipShape(Circle())
                                Text(channel.name ?? "")
                                    .font(AnixartFont.body)
                                    .foregroundColor(AnixartColor.textPrimary)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .background(AnixartColor.background)
                        }
                    }
                    .listStyle(.plain)
                    .background(AnixartColor.background)
                }
            }
        }
        .navigationTitle("Подписки")
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
        ZStack {
            AnixartColor.background.ignoresSafeArea()
            Group {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
                } else {
                    List(collections) { collection in
                        NavigationLink(destination: CollectionDetailView(collectionId: collection.id)) {
                            HStack(spacing: 14) {
                                CachedImage(url: collection.image)
                                    .frame(width: 56, height: 56)
                                    .cornerRadius(12)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(collection.name)
                                        .font(AnixartFont.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AnixartColor.textPrimary)
                                    Text("\(collection.releasesCount ?? 0) релизов")
                                        .font(AnixartFont.small)
                                        .foregroundColor(AnixartColor.textSecondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .background(AnixartColor.background)
                        }
                    }
                    .listStyle(.plain)
                    .background(AnixartColor.background)
                }
            }
        }
        .navigationTitle("Коллекции")
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            do {
                collections = try await CollectionAPI().getAll(page: 1).items ?? []
            } catch {}
            isLoading = false
        }
    }
}
