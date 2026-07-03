import SwiftUI

struct HomeView: View {
    @State private var latestReleases: [ReleaseCompact] = []
    @State private var feedArticles: [ArticleCompact] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .padding(.top, 100)
                } else if let error {
                    VStack(spacing: 16) {
                        Text(error).foregroundColor(.secondary)
                        Button("Обновить") { Task { await loadData() } }
                    }
                    .padding(.top, 100)
                } else {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        if !latestReleases.isEmpty {
                            SectionHeader(title: "Последние релизы", action: {})
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(latestReleases) { release in
                                        NavigationLink(value: release) {
                                            ReleaseCard(release: release)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        if !feedArticles.isEmpty {
                            SectionHeader(title: "Лента", action: {})
                            ForEach(feedArticles) { article in
                                NavigationLink(value: article) {
                                    ArticleRow(article: article)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .refreshable { await loadData() }
            .navigationTitle("Anixart")
            .navigationDestination(for: ReleaseCompact.self) { release in
                ReleaseDetailView(releaseId: release.id)
            }
            .navigationDestination(for: ArticleCompact.self) { article in
                ArticleDetailView(articleId: article.id)
            }
            .task { await loadData() }
        }
    }

    func loadData() async {
        isLoading = true
        error = nil
        do {
            async let latest = FeedAPI().getLatest()
            async let feed = FeedAPI().getAll(page: 1)
            let (l, f) = try await (latest, feed)
            latestReleases = l
            feedArticles = f.items ?? []
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

struct SectionHeader: View {
    let title: String
    let action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            Button("Все") { action?() }
                .font(.subheadline)
        }
        .padding(.horizontal)
    }
}

struct ReleaseCard: View {
    let release: ReleaseCompact

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CachedImage(url: release.poster?.preview)
                .frame(width: 140, height: 200)
                .cornerRadius(12)

            Text(release.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)

            if let rating = release.rating {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .foregroundColor(.primary)
    }
}

struct ArticleRow: View {
    let article: ArticleCompact

    var body: some View {
        HStack(spacing: 12) {
            CachedImage(url: article.image)
                .frame(width: 80, height: 80)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(article.title ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                Text(article.channelName ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "bubble.left")
                        .font(.caption2)
                    Text("\(article.commentsCount ?? 0)")
                        .font(.caption2)
                    Spacer()
                    if let date = article.createdAt {
                        Text(date.replacingOccurrences(of: "T", with: " ").prefix(16))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .foregroundColor(.primary)
    }
}
