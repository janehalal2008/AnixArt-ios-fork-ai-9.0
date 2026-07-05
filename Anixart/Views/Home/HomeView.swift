import SwiftUI

struct HomeView: View {
    @State private var latestReleases: [ReleaseCompact] = []
    @State private var feedArticles: [ArticleCompact] = []
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AnixartColor.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    if isLoading {
                        ProgressView()
                            .tint(AnixartColor.accent)
                            .padding(.top, 120)
                    } else if let error {
                        VStack(spacing: 16) {
                            Text(error)
                                .foregroundColor(AnixartColor.textSecondary)
                                .multilineTextAlignment(.center)
                            Button("Обновить") { Task { await loadData() } }
                                .foregroundColor(AnixartColor.accent)
                        }
                        .padding(.top, 120)
                        .padding(.horizontal)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 28) {
                            if !latestReleases.isEmpty {
                                SectionHeader(title: "Последние релизы")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 14) {
                                        ForEach(latestReleases) { release in
                                            NavigationLink(value: release) {
                                                AnixartReleaseCard(release: release)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }

                            if !feedArticles.isEmpty {
                                SectionHeader(title: "Лента")
                                LazyVStack(spacing: 12) {
                                    ForEach(feedArticles) { article in
                                        NavigationLink(value: article) {
                                            AnixartArticleRow(article: article)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                }
                .refreshable { await loadData() }
            }
            .navigationTitle("Anixart")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AnixartColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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

    var body: some View {
        HStack {
            Text(title)
                .font(AnixartFont.headline)
                .foregroundColor(AnixartColor.textPrimary)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct AnixartReleaseCard: View {
    let release: ReleaseCompact

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                CachedImage(url: release.poster?.preview)
                    .frame(width: 150, height: 220)
                    .cornerRadius(16)

                if let rating = release.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AnixartColor.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(AnixartFont.small)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .padding(8)
                }
            }

            Text(release.name)
                .font(AnixartFont.caption)
                .foregroundColor(AnixartColor.textPrimary)
                .lineLimit(2)
                .frame(width: 150, alignment: .leading)

            Text(release.status?.displayName ?? "")
                .font(AnixartFont.small)
                .foregroundColor(AnixartColor.textSecondary)
                .lineLimit(1)
                .frame(width: 150, alignment: .leading)
        }
    }
}

struct AnixartArticleRow: View {
    let article: ArticleCompact

    var body: some View {
        HStack(spacing: 14) {
            CachedImage(url: article.image)
                .frame(width: 90, height: 90)
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 6) {
                Text(article.title ?? "")
                    .font(AnixartFont.body)
                    .fontWeight(.semibold)
                    .foregroundColor(AnixartColor.textPrimary)
                    .lineLimit(2)

                Text(article.channelName ?? "")
                    .font(AnixartFont.small)
                    .foregroundColor(AnixartColor.accentPurple)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 11))
                        .foregroundColor(AnixartColor.textSecondary)
                    Text("\(article.commentsCount ?? 0)")
                        .font(AnixartFont.small)
                        .foregroundColor(AnixartColor.textSecondary)
                    Spacer()
                    if let date = article.createdAt {
                        Text(date.replacingOccurrences(of: "T", with: " ").prefix(16))
                            .font(AnixartFont.small)
                            .foregroundColor(AnixartColor.textSecondary)
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .background(AnixartColor.surface)
        .cornerRadius(16)
    }
}
