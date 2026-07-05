import SwiftUI

struct CatalogView: View {
    @State private var releases: [ReleaseCompact] = []
    @State private var selectedStatus: String?
    @State private var selectedSort = "rating"
    @State private var isLoading = true
    @State private var page = 1
    @State private var hasMore = true

    let statuses: [(String, String)] = [
        ("", "Все"), ("ONGOING", "Онгоинг"), ("COMPLETED", "Завершён"),
        ("ANNOUNCED", "Анонс"), ("PAUSED", "Заморожен")
    ]

    let sortOptions: [(String, String)] = [
        ("rating", "По рейтингу"), ("year", "По году"),
        ("name", "По названию"), ("episodes", "По эпизодам")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AnixartColor.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(statuses, id: \.0) { status in
                                AnixartFilterChip(
                                    text: status.1,
                                    isSelected: selectedStatus == status.0 || (status.0.isEmpty && selectedStatus == nil)
                                ) {
                                    selectedStatus = status.0.isEmpty ? nil : status.0
                                    page = 1
                                    Task { await loadReleases() }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                    }

                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(releases) { release in
                                NavigationLink(value: release) {
                                    AnixartGridCard(release: release)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }

                            if hasMore {
                                ProgressView()
                                    .tint(AnixartColor.accent)
                                    .task { await loadMore() }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 80)
                    }
                }
            }
            .navigationTitle("Каталог")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AnixartColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: ReleaseCompact.self) { release in
                ReleaseDetailView(releaseId: release.id)
            }
            .task { await loadReleases() }
        }
    }

    func loadReleases() async {
        isLoading = true
        page = 1
        do {
            let api = ReleaseAPI()
            let result = try await api.search(page: page, status: selectedStatus, sort: selectedSort)
            releases = result.items ?? []
            hasMore = (result.page ?? 1) < (result.totalPages ?? 1)
        } catch {}
        isLoading = false
    }

    func loadMore() async {
        page += 1
        do {
            let api = ReleaseAPI()
            let result = try await api.search(page: page, status: selectedStatus, sort: selectedSort)
            releases.append(contentsOf: result.items ?? [])
            hasMore = (result.page ?? page) < (result.totalPages ?? 1)
        } catch { page -= 1 }
    }
}

struct AnixartFilterChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(AnixartFont.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AnixartColor.accent : AnixartColor.surface)
                .foregroundColor(isSelected ? .white : AnixartColor.textSecondary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AnixartGridCard: View {
    let release: ReleaseCompact

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomLeading) {
                CachedImage(url: release.poster?.preview)
                    .aspectRatio(3/4, contentMode: .fill)
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
                .fontWeight(.semibold)
                .lineLimit(2)

            Text(release.status?.displayName ?? "")
                .font(AnixartFont.small)
                .foregroundColor(AnixartColor.textSecondary)
                .lineLimit(1)
        }
    }
}
