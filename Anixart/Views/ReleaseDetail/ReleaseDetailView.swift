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
        ScrollView {
            if isLoading {
                ProgressView().padding(.top, 100)
            } else if let error {
                Text(error).foregroundColor(.secondary).padding(.top, 100)
            } else if let release {
                VStack(alignment: .leading, spacing: 16) {
                    CachedImage(url: release.poster?.big ?? release.poster?.default)
                        .aspectRatio(16/9, contentMode: .fill)
                        .cornerRadius(12)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(release.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 16) {
                            if let rating = release.rating {
                                Label(String(format: "%.1f", rating), systemImage: "star.fill")
                                    .foregroundColor(.yellow)
                            }
                            if let year = release.year {
                                Text("\(year)")
                            }
                            Text(release.status?.displayName ?? "")
                                .foregroundColor(.secondary)
                            if let eps = release.episodes {
                                Text("\(eps)/\(release.episodesTotal ?? eps) эп.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.subheadline)

                        if let types = release.types, !types.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(types) { type in
                                        Button(type.name) {
                                            selectedType = type
                                            Task { await loadEpisodes() }
                                        }
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedType?.id == type.id ? Color.accentColor : Color(.systemGray6))
                                        .foregroundColor(selectedType?.id == type.id ? .white : .primary)
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }

                        if let description = release.description {
                            Text(description)
                                .font(.body)
                                .lineLimit(nil)
                        }

                        if release.genres?.isEmpty == false {
                            Text("Жанры: \(release.genres?.map(\.name).joined(separator: ", ") ?? "")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
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
        .navigationBarTitleDisplayMode(.inline)
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
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)

            if !sources.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(sources) { source in
                            Button(source.name) {
                                selectedSource = source
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedSource?.id == source.id ? Color.accentColor : Color(.systemGray6))
                            .foregroundColor(selectedSource?.id == source.id ? .white : .primary)
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
                        EpisodeRow(episode: episode)
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct EpisodeRow: View {
    let episode: Episode

    var body: some View {
        HStack {
            Text("\(episode.position)")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(width: 32)

            VStack(alignment: .leading) {
                Text(episode.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let hosting = episode.sources?.first?.hosting {
                    Text(hosting)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "play.circle.fill")
                .font(.title3)
                .foregroundColor(.accentColor)
        }
        .padding(.vertical, 8)
        .foregroundColor(.primary)
    }
}
