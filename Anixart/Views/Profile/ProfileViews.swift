import SwiftUI

struct ProfileView: View {
    let profileId: Int
    @State private var profile: Profile?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView().padding(.top, 100)
            } else if let profile {
                VStack(spacing: 20) {
                    CachedImage(url: profile.avatarBig ?? profile.avatar)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())

                    Text(profile.login ?? "")
                        .font(.title2)
                        .fontWeight(.bold)

                    if let status = profile.customStatus ?? profile.status {
                        Text(status)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let description = profile.description {
                        Text(description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    HStack(spacing: 32) {
                        VStack {
                            Text("\(profile.followerCount ?? 0)")
                                .font(.headline)
                            Text("Подписчики")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        VStack {
                            Text("\(profile.followingCount ?? 0)")
                                .font(.headline)
                            Text("Подписки")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(profile?.login ?? "Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                profile = try await ProfileAPI().getProfile(id: profileId)
            } catch {}
            isLoading = false
        }
    }
}

struct ChannelDetailView: View {
    let channelId: Int
    @State private var channel: Channel?
    @State private var articles: [Article] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView().padding(.top, 100)
            } else if let channel {
                VStack(alignment: .leading, spacing: 16) {
                    CachedImage(url: channel.cover)
                        .frame(height: 160)
                        .clipped()

                    HStack(spacing: 16) {
                        CachedImage(url: channel.avatar)
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            .offset(y: -32)
                            .padding(.bottom, -32)

                        VStack(alignment: .leading) {
                            Text(channel.name ?? "")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("\(channel.subscribersCount ?? 0) подписчиков")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    if let description = channel.description {
                        Text(description)
                            .font(.body)
                            .padding(.horizontal)
                    }

                    if !articles.isEmpty {
                        Text("Статьи")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        ForEach(articles) { article in
                            NavigationLink(destination: ArticleDetailView(articleId: article.id)) {
                                ArticleRow(article: ArticleCompact(
                                    id: article.id,
                                    title: article.title,
                                    image: article.image,
                                    profile: article.profile,
                                    channelName: channel.name,
                                    commentsCount: article.commentsCount,
                                    createdAt: article.createdAt
                                ))
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(channel?.name ?? "Канал")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                async let c = ChannelAPI().getChannel(id: channelId)
                async let a = ChannelAPI().getArticles(id: channelId, page: 1)
                (channel, articles) = try await (c, a.items ?? [])
            } catch {}
            isLoading = false
        }
    }
}

struct CollectionDetailView: View {
    let collectionId: Int
    @State private var collection: Collection?
    @State private var releases: [ReleaseCompact] = []
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView().padding(.top, 100)
            } else if let collection {
                VStack(alignment: .leading, spacing: 16) {
                    CachedImage(url: collection.imageBig ?? collection.image)
                        .frame(height: 200)
                        .clipped()

                    VStack(alignment: .leading, spacing: 8) {
                        Text(collection.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let description = collection.description {
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Text("\(collection.releasesCount ?? 0) релизов")
                            Text("•")
                            Text("\(collection.subscribersCount ?? 0) подписчиков")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(releases) { release in
                            NavigationLink(value: release) {
                                ReleaseGridCard(release: release)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(collection?.name ?? "Коллекция")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: ReleaseCompact.self) { release in
            ReleaseDetailView(releaseId: release.id)
        }
        .task {
            do {
                async let c = CollectionAPI().getCollection(id: collectionId)
                async let r = CollectionAPI().getReleases(id: collectionId, page: 1)
                (collection, releases) = try await (c, r.items ?? [])
            } catch {}
            isLoading = false
        }
    }
}

struct ArticleDetailView: View {
    let articleId: Int
    @State private var article: Article?
    @State private var isLoading = true

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView().padding(.top, 100)
            } else if let article {
                VStack(alignment: .leading, spacing: 16) {
                    if let image = article.image {
                        CachedImage(url: image)
                            .frame(height: 200)
                            .clipped()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text(article.title ?? "")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack {
                            Text(article.profile?.login ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let date = article.createdAt {
                                Text("•")
                                Text(date.replacingOccurrences(of: "T", with: " ").prefix(16))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if let content = article.content {
                            Text(content)
                                .font(.body)
                        }

                        HStack(spacing: 24) {
                            Label("\(article.votes?.up ?? 0)", systemImage: "hand.thumbsup")
                            Label("\(article.commentsCount ?? 0)", systemImage: "bubble.left")
                            Label("\(article.repostsCount ?? 0)", systemImage: "arrowshape.turn.up.right")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(article?.title ?? "Статья")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            do {
                article = try await ArticleAPI().getArticle(id: articleId)
            } catch {}
            isLoading = false
        }
    }
}

struct NotificationsView: View {
    @State private var notifications: [NotificationItem] = []
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if notifications.isEmpty {
                ContentUnavailableView("Нет уведомлений", systemImage: "bell.slash", description: Text("У вас пока нет уведомлений"))
            } else {
                List(notifications) { notification in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(notification.profile?.login ?? "Система")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Spacer()
                            if let date = notification.createdAt {
                                Text(date.replacingOccurrences(of: "T", with: " ").prefix(10))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if let text = notification.commentText {
                            Text(text)
                                .font(.body)
                                .lineLimit(2)
                        }
                        if let name = notification.releaseName {
                            Text(name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Уведомления")
        .task {
            do {
                notifications = try await NotificationAPI().getAll(page: 1).items ?? []
            } catch {}
            isLoading = false
        }
    }
}
