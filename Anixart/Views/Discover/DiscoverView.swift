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
            ScrollView {
                if isLoading {
                    ProgressView().padding(.top, 100)
                } else {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        if !interesting.isEmpty {
                            SectionHeader(title: "Интересное", action: {})
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(interesting) { release in
                                        NavigationLink(value: release) {
                                            ReleaseCard(release: release)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        if !recommendations.isEmpty {
                            SectionHeader(title: "Рекомендации", action: {})
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(recommendations) { release in
                                        NavigationLink(value: release) {
                                            ReleaseCard(release: release)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        if !watching.isEmpty {
                            SectionHeader(title: "Смотрят", action: {})
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(watching) { release in
                                        NavigationLink(value: release) {
                                            ReleaseCard(release: release)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        if !discussing.isEmpty {
                            SectionHeader(title: "Обсуждают", action: {})
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(discussing) { release in
                                        NavigationLink(value: release) {
                                            ReleaseCard(release: release)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        if !commentsOfWeek.isEmpty {
                            SectionHeader(title: "Комментарии недели", action: {})
                            ForEach(commentsOfWeek) { comment in
                                CommentWeekRow(comment: comment)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Обзор")
            .navigationDestination(for: ReleaseCompact.self) { release in
                ReleaseDetailView(releaseId: release.id)
            }
            .refreshable { await loadData() }
            .task { await loadData() }
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

struct CommentWeekRow: View {
    let comment: CommentWeek

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.profile?.login ?? "")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "hand.thumbsup.fill")
                    .font(.caption)
                    .foregroundColor(.accentColor)
                Text("\(comment.voteUp ?? 0)")
                    .font(.caption)
            }

            Text(comment.text ?? "")
                .font(.body)
                .lineLimit(3)

            if let releaseName = comment.releaseName {
                Text("На релизе: \(releaseName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
