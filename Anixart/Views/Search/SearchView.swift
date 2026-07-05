import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var searchResults: [ReleaseCompact] = []
    @State private var collections: [CollectionCompact] = []
    @State private var profiles: [ProfileSlim] = []
    @State private var channels: [ChannelCompact] = []
    @State private var isLoading = false
    @State private var selectedScope = 0

    let scopes = ["Релизы", "Коллекции", "Профили", "Каналы"]

    var body: some View {
        NavigationStack {
            ZStack {
                AnixartColor.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(0..<scopes.count, id: \.self) { i in
                                AnixartFilterChip(
                                    text: scopes[i],
                                    isSelected: selectedScope == i
                                ) {
                                    selectedScope = i
                                    Task { await performSearch() }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }

                    if query.isEmpty {
                        Spacer()
                        ContentUnavailableView(
                            "Поиск",
                            systemImage: "magnifyingglass",
                            description: Text("Введите название аниме, коллекции, профиля или канала")
                        )
                        .foregroundColor(AnixartColor.textSecondary)
                        Spacer()
                    } else if isLoading {
                        Spacer()
                        ProgressView()
                            .tint(AnixartColor.accent)
                        Spacer()
                    } else {
                        List {
                            switch selectedScope {
                            case 0:
                                ForEach(searchResults) { release in
                                    NavigationLink(value: release) {
                                        AnixartListReleaseRow(release: release)
                                    }
                                }
                            case 1:
                                ForEach(collections) { collection in
                                    NavigationLink(destination: CollectionDetailView(collectionId: collection.id ?? 0)) {
                                        HStack(spacing: 14) {
                                            CachedImage(url: collection.image)
                                                .frame(width: 56, height: 56)
                                                .cornerRadius(12)
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(collection.name ?? "")
                                                    .font(AnixartFont.body)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(AnixartColor.textPrimary)
                                                Text(collection.profile?.login ?? "")
                                                    .font(AnixartFont.small)
                                                    .foregroundColor(AnixartColor.textSecondary)
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                        .background(AnixartColor.background)
                                    }
                                }
                            case 2:
                                ForEach(profiles) { profile in
                                    NavigationLink(destination: ProfileView(profileId: profile.id)) {
                                        HStack(spacing: 14) {
                                            CachedImage(url: profile.avatar)
                                                .frame(width: 48, height: 48)
                                                .clipShape(Circle())
                                            Text(profile.login ?? "")
                                                .font(AnixartFont.body)
                                                .foregroundColor(AnixartColor.textPrimary)
                                            Spacer()
                                        }
                                        .padding(.vertical, 4)
                                        .background(AnixartColor.background)
                                    }
                                }
                            case 3:
                                ForEach(channels) { channel in
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
                            default:
                                EmptyView()
                            }
                        }
                        .listStyle(.plain)
                        .background(AnixartColor.background)
                    }
                }
            }
            .navigationTitle("Поиск")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AnixartColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: ReleaseCompact.self) { release in
                ReleaseDetailView(releaseId: release.id)
            }
            .searchable(text: $query, prompt: "Название, коллекция, профиль...")
            .tint(AnixartColor.accent)
            .onChange(of: query) { _, _ in
                Task { await performSearch() }
            }
        }
    }

    func performSearch() async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            collections = []
            profiles = []
            channels = []
            return
        }

        isLoading = true
        do {
            let searchAPI = SearchAPI()
            switch selectedScope {
            case 0:
                let result = try await searchAPI.searchReleases(page: 1, query: query)
                searchResults = result.items ?? []
            case 1:
                let result = try await searchAPI.searchCollections(page: 1, query: query)
                collections = result.items ?? []
            case 2:
                let result = try await searchAPI.searchProfiles(page: 1, query: query)
                profiles = result.items ?? []
            case 3:
                let result = try await searchAPI.searchChannels(page: 1, query: query)
                channels = result.items ?? []
            default: break
            }
        } catch {}
        isLoading = false
    }
}

struct SearchReleaseRow: View {
    let release: ReleaseCompact

    var body: some View {
        HStack(spacing: 12) {
            CachedImage(url: release.poster?.preview)
                .frame(width: 48, height: 68)
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 4) {
                Text(release.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                if let rating = release.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .foregroundColor(.primary)
    }
}
