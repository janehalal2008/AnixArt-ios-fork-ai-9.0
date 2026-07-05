import SwiftUI

struct DiscoverView: View {
    @State private var interesting: [ReleaseCompact] = []
    @State private var recommendations: [ReleaseCompact] = []
    @State private var watching: [ReleaseCompact] = []
    @State private var discussing: [ReleaseCompact] = []
    @State private var commentsOfWeek: [CommentWeek] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            ZStack {
                AnixartColor.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    if isLoading {
                        ProgressView()
                            .tint(AnixartColor.accent)
                            .padding(.top, 120)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 28) {
                            horizontalSection(title: "Интересное", releases: interesting)
                            horizontalSection(title: "Рекомендации", releases: recommendations)
                            horizontalSection(title: "Смотрят", releases: watching)
                            horizontalSection(title: "Обсуждают", releases: discussing)

                            if !commentsOfWeek.isEmpty {
                                SectionHeader(title: "Комментарии недели")
                                LazyVStack(spacing: 12) {
                                    ForEach(commentsOfWeek) { comment in
                                        AnixartCommentWeekRow(comment: comment)
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
            .navigationTitle("Обзор")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AnixartColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: ReleaseCompact.self) { release in
                ReleaseDetailView(releaseId: release.id)
            }
            .task { await loadData() }
        }
    }

    private func horizontalSection(title: String, releases: [ReleaseCompact]) -> some View {
        Group {
            if !releases.isEmpty {
                SectionHeader(title: title)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(releases) { release in
                            NavigationLink(value: release) {
                                AnixartReleaseCard(release: release)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    func loadData() async {
        isLoading = true
        do {
            async let interestingTask = DiscoverAPI().getInteresting()
            async let recTask = DiscoverAPI().getRecommendations(page: 1)
            async let watchingTask = DiscoverAPI().getWatching(page: 1)
            async let discussingTask = DiscoverAPI().getDiscussing()
            async let commentsTask = DiscoverAPI().getComments()
            let (i, recResp, wResp, d, c) = try await (interestingTask, recTask, watchingTask, discussingTask, commentsTask)
            interesting = i
            recommendations = recResp.items ?? []
            watching = wResp.items ?? []
            discussing = d
            commentsOfWeek = c
        } catch {}
        isLoading = false
    }
}

struct AnixartCommentWeekRow: View {
    let comment: CommentWeek

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 10) {
                    CachedImage(url: comment.profile?.avatar)
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                    Text(comment.profile?.login ?? "")
                        .font(AnixartFont.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AnixartColor.textPrimary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "hand.thumbsup.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AnixartColor.accent)
                    Text("\(comment.voteUp ?? 0)")
                        .font(AnixartFont.small)
                        .foregroundColor(AnixartColor.textSecondary)
                }
            }

            Text(comment.text ?? "")
                .font(AnixartFont.body)
                .foregroundColor(AnixartColor.textPrimary)
                .lineLimit(3)

            if let releaseName = comment.releaseName {
                Text("На релизе: \(releaseName)")
                    .font(AnixartFont.small)
                    .foregroundColor(AnixartColor.accentPurple)
            }
        }
        .padding()
        .background(AnixartColor.surface)
        .cornerRadius(16)
    }
}
