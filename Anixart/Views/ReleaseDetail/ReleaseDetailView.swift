import SwiftUI

struct ReleaseDetailView: View {
    let releaseId: Int
    @State private var release: Release?
    @State private var episodes: EpisodeResponse?
    @State private var selectedType: TypeItem?
    @State private var selectedSource: Source?
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
                        .padding(.top, 120)
                } else if let error {
                    Text(error)
                        .foregroundColor(AnixartColor.textSecondary)
                        .padding(.top, 120)
                } else if let release {
                    VStack(alignment: .leading, spacing: 16) {
                        CachedImage(url: release.poster?.big ?? release.poster?.default)
                            .aspectRatio(16/9, contentMode: .fill)
                            .cornerRadius(16)
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(release.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AnixartColor.textPrimary)

                            HStack(spacing: 16) {
                                if let rating = release.rating {
                                    Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                        .foregroundColor(AnixartColor.yellow)
                                }
                                if let year = release.year {
                                    Text("\(year)")
                                        .foregroundColor(AnixartColor.textSecondary)
                                }
                                Text(release.status?.displayName ?? "")
                                    .foregroundColor(AnixartColor.textSecondary)
                                if let eps = release.episodes {
                                    Text("\(eps)/\(release.episodesTotal ?? eps) эп.")
                                        .foregroundColor(AnixartColor.textSecondary)
                                }
                            }
                            .font(AnixartFont.caption)

                            if let types = release.types, !types.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(types) { type in
                                            Button(type.name) {
                                                selectedType = type
                                                Task { await loadEpisodes() }
                                            }
                                            .font(AnixartFont.small)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedType?.id == type.id ? AnixartColor.accent : AnixartColor.surface)
                                            .foregroundColor(selectedType?.id == type.id ? .white : AnixartColor.textPrimary)
                                            .cornerRadius(16)
                                        }
                                    }
                                }
                            }

                            if let description = release.description {
                                Text(description)
                                    .font(AnixartFont.body)
                                    .foregroundColor(AnixartColor.textSecondary)
                                    .lineLimit(nil)
                            }

                            if release.genres?.isEmpty == false {
                                Text("Жанры: \(release.genres?.map(\.name).joined(separator: ", ") ?? "")")
                                    .font(AnixartFont.caption)
                                    .foregroundColor(AnixartColor.textSecondary)
                            }
                        }
                        .padding(.horizontal)

                        if let episodes {
                            EpisodesSection(
                                episodes: episodes.episodes ?? [],
                                sources: episodes.sources ?? [],
                                selectedSource: $selectedSource,
                                releaseId: releaseId
                            )
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await loadData() }
    }

    func loadData() async {
        isLoading = true
        do {
            async let r = ReleaseAPI().getRelease(id: releaseId)
            async let e = EpisodeAPI().getEpisodes(releaseId: releaseId)
            let (releaseResp, epResp) = try await (r, e)
            release = releaseResp.release
            episodes = epResp
            selectedType = epResp.typeCurrent ?? epResp.types?.first
            selectedSource = epResp.sources?.first
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }

    func loadEpisodes() async {
        guard let typeId = selectedType?.id else { return }
        do {
            episodes = try await EpisodeAPI().getEpisodes(releaseId: releaseId, typeId: typeId)
            selectedSource = episodes?.sources?.first
        } catch {}
    }
}

struct EpisodesSection: View {
    let episodes: [Episode]
    let sources: [Source]
    @Binding var selectedSource: Source?
    let releaseId: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Эпизоды")
                .font(AnixartFont.headline)
                .foregroundColor(AnixartColor.textPrimary)
                .padding(.horizontal)

            if !sources.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(sources) { source in
                            Button(source.name) {
                                selectedSource = source
                            }
                            .font(AnixartFont.small)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedSource?.id == source.id ? AnixartColor.accent : AnixartColor.surface)
                            .foregroundColor(selectedSource?.id == source.id ? .white : AnixartColor.textPrimary)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
            }

            LazyVStack(spacing: 8) {
                ForEach(episodes) { episode in
                    NavigationLink(destination: PlayerView(
                        episode: episode,
                        source: selectedSource,
                        releaseId: releaseId
                    )) {
                        AnixartEpisodeRow(episode: episode)
                            .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

struct AnixartEpisodeRow: View {
    let episode: Episode

    var body: some View {
        HStack {
            Text("\(episode.position)")
                .font(AnixartFont.headline)
                .foregroundColor(AnixartColor.textSecondary)
                .frame(width: 32)

            VStack(alignment: .leading) {
                Text(episode.name)
                    .font(AnixartFont.body)
                    .fontWeight(.medium)
                    .foregroundColor(AnixartColor.textPrimary)
                if let hosting = episode.sources?.first?.hosting {
                    Text(hosting)
                        .font(AnixartFont.small)
                        .foregroundColor(AnixartColor.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "play.circle.fill")
                .font(.title3)
                .foregroundColor(AnixartColor.accent)
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(AnixartColor.surface)
        .cornerRadius(12)
    }
}
