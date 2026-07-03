import SwiftUI

struct CatalogView: View {
    @State private var releases: [ReleaseCompact] = []
    @State private var genres: [Genre] = []
    @State private var types: [TypeItem] = []
    @State private var selectedGenre: Int?
    @State private var selectedStatus: String?
    @State private var selectedYear: Int?
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
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(statuses, id: \.0) { status in
                            FilterChip(
                                text: status.1,
                                isSelected: selectedStatus == status.0 || (status.0.isEmpty && selectedStatus == nil)
                            ) {
                                selectedStatus = status.0.isEmpty ? nil : status.0
                                page = 1
                                Task { await loadReleases() }
                            }
                        }
                    }
                    .padding()
                }

                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(releases) { release in
                            NavigationLink(value: release) {
                                ReleaseGridCard(release: release)
                            }
                        }

                        if hasMore {
                            ProgressView()
                                .task { await loadMore() }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Каталог")
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

struct FilterChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct ReleaseGridCard: View {
    let release: ReleaseCompact

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CachedImage(url: release.poster?.preview)
                .aspectRatio(3/4, contentMode: .fill)
                .cornerRadius(12)

            Text(release.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)

            HStack {
                if let rating = release.rating {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(.caption2)
                }
                Spacer()
                Text(release.status?.displayName ?? "")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.primary)
    }
}
