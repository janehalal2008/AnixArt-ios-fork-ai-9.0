import SwiftUI

struct ProfileView: View {
    let profileId: Int
    @State private var profile: Profile?
    @State private var isLoading = true

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
                        .padding(.top, 120)
                } else if let profile {
                    VStack(spacing: 24) {
                        CachedImage(url: profile.avatarBig ?? profile.avatar)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AnixartColor.accent, lineWidth: 3))

                        Text(profile.login ?? "")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(AnixartColor.textPrimary)

                        if let status = profile.customStatus ?? profile.status {
                            Text(status)
                                .font(AnixartFont.body)
                                .foregroundColor(AnixartColor.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        if let description = profile.description {
                            Text(description)
                                .font(AnixartFont.body)
                                .foregroundColor(AnixartColor.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        HStack(spacing: 40) {
                            VStack(spacing: 4) {
                                Text("\(profile.followerCount ?? 0)")
                                    .font(AnixartFont.headline)
                                    .foregroundColor(AnixartColor.textPrimary)
                                Text("Подписчики")
                                    .font(AnixartFont.small)
                                    .foregroundColor(AnixartColor.textSecondary)
                            }
                            VStack(spacing: 4) {
                                Text("\(profile.followingCount ?? 0)")
                                    .font(AnixartFont.headline)
                                    .foregroundColor(AnixartColor.textPrimary)
                                Text("Подписки")
                                    .font(AnixartFont.small)
                                    .foregroundColor(AnixartColor.textSecondary)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle(profile?.login ?? "Профиль")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
                        .padding(.top, 120)
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
                                .overlay(Circle().stroke(AnixartColor.accent, lineWidth: 2))

                            VStack(alignment: .leading) {
                                Text(channel.name ?? "")
                                    .font(AnixartFont.headline)
                                    .foregroundColor(AnixartColor.textPrimary)
                                Text("\(channel.subscribersCount ?? 0) подписчиков")
                                    .font(AnixartFont.caption)
                                    .foregroundColor(AnixartColor.textSecondary)
                            }
                        }
                        .padding(.horizontal)

                        if let description = channel.description {
                            Text(description)
                                .font(AnixartFont.body)
                                .foregroundColor(AnixartColor.textSecondary)
                                .padding(.horizontal)
                        }

                        if !articles.isEmpty {
                            SectionHeader(title: "Статьи")
                                .padding(.top, 16)

                            LazyVStack(spacing: 12) {
                                ForEach(articles) { article in
                                    NavigationLink(destination: ArticleDetailView(articleId: article.id)) {
                                        AnixartArticleRow(article: ArticleCompact(
                                            id: article.id,
                                            title: article.title,
                                            image: article.image,
                                            profile: article.profile,
                                            channelName: channel.name,
                                            commentsCount: article.commentsCount,
                                            createdAt: article.createdAt
                                        ))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(channel?.name ?? "Канал")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
                        .padding(.top, 120)
                } else if let collection {
                    VStack(alignment: .leading, spacing: 16) {
                        CachedImage(url: collection.imageBig ?? collection.image)
                            .frame(height: 200)
                            .clipped()

                        VStack(alignment: .leading, spacing: 8) {
                            Text(collection.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AnixartColor.textPrimary)

                            if let description = collection.description {
                                Text(description)
                                    .font(AnixartFont.body)
                                    .foregroundColor(AnixartColor.textSecondary)
                            }

                            HStack {
                                Text("\(collection.releasesCount ?? 0) релизов")
                                Text("•")
                                Text("\(collection.subscribersCount ?? 0) подписчиков")
                            }
                            .font(AnixartFont.caption)
                            .foregroundColor(AnixartColor.textSecondary)
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(releases) { release in
                                NavigationLink(value: release) {
                                    AnixartGridCard(release: release)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle(collection?.name ?? "Коллекция")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
                        .padding(.top, 120)
                } else if let article {
                    VStack(alignment: .leading, spacing: 16) {
                        if let image = article.image {
                            CachedImage(url: image)
                                .frame(height: 200)
                                .clipped()
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text(article.title ?? "")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(AnixartColor.textPrimary)

                            HStack {
                                Text(article.profile?.login ?? "")
                                    .font(AnixartFont.caption)
                                    .foregroundColor(AnixartColor.accentPurple)
                                if let date = article.createdAt {
                                    Text("•")
                                        .foregroundColor(AnixartColor.textSecondary)
                                    Text(date.replacingOccurrences(of: "T", with: " ").prefix(16))
                                        .font(AnixartFont.small)
                                        .foregroundColor(AnixartColor.textSecondary)
                                }
                            }

                            if let content = article.content {
                                Text(content)
                                    .font(AnixartFont.body)
                                    .foregroundColor(AnixartColor.textSecondary)
                            }

                            HStack(spacing: 24) {
                                Label("\(article.votes?.up ?? 0)", systemImage: "hand.thumbsup")
                                Label("\(article.commentsCount ?? 0)", systemImage: "bubble.left")
                                Label("\(article.repostsCount ?? 0)", systemImage: "arrowshape.turn.up.right")
                            }
                            .font(AnixartFont.caption)
                            .foregroundColor(AnixartColor.textSecondary)
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle(article?.title ?? "Статья")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
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
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            Group {
                if isLoading {
                    ProgressView()
                        .tint(AnixartColor.accent)
                } else if notifications.isEmpty {
                    ContentUnavailableView("Нет уведомлений", systemImage: "bell.slash", description: Text("У вас пока нет уведомлений"))
                } else {
                    List(notifications) { notification in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(notification.profile?.login ?? "Система")
                                    .font(AnixartFont.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AnixartColor.textPrimary)
                                Spacer()
                                if let date = notification.createdAt {
                                    Text(date.replacingOccurrences(of: "T", with: " ").prefix(10))
                                        .font(AnixartFont.small)
                                        .foregroundColor(AnixartColor.textSecondary)
                                }
                            }
                            if let text = notification.commentText {
                                Text(text)
                                    .font(AnixartFont.body)
                                    .foregroundColor(AnixartColor.textSecondary)
                                    .lineLimit(2)
                            }
                            if let name = notification.releaseName {
                                Text(name)
                                    .font(AnixartFont.small)
                                    .foregroundColor(AnixartColor.accentPurple)
                            }
                        }
                        .padding(.vertical, 4)
                        .background(AnixartColor.background)
                    }
                    .listStyle(.plain)
                    .background(AnixartColor.background)
                }
            }
        }
        .navigationTitle("Уведомления")
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            do {
                notifications = try await NotificationAPI().getAll(page: 1).items ?? []
            } catch {}
            isLoading = false
        }
    }
}
