import SwiftUI

struct DebugView: View {
    @StateObject private var logger = APILogger.shared
    @State private var selectedEntry: APILogger.LogEntry?
    @State private var filterText = ""

    private var filteredEntries: [APILogger.LogEntry] {
        if filterText.isEmpty { return logger.entries }
        return logger.entries.filter {
            $0.url.localizedCaseInsensitiveContains(filterText) ||
            $0.response.localizedCaseInsensitiveContains(filterText) ||
            ($0.error?.localizedCaseInsensitiveContains(filterText) ?? false)
        }
    }

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AnixartColor.textSecondary)
                    TextField("Фильтр по URL/ответу...", text: $filterText)
                        .foregroundColor(AnixartColor.textPrimary)
                    if !filterText.isEmpty {
                        Button("Сбросить") { filterText = "" }
                            .font(AnixartFont.caption)
                            .foregroundColor(AnixartColor.accent)
                    }
                }
                .padding(12)
                .background(AnixartColor.surface)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)

                List {
                    ForEach(filteredEntries) { entry in
                        Button {
                            selectedEntry = entry
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(entry.method)
                                        .font(AnixartFont.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(statusColor(entry.status))
                                    Text(statusText(entry.status))
                                        .font(AnixartFont.small)
                                        .foregroundColor(statusColor(entry.status))
                                    Spacer()
                                    Text(entry.timestamp, style: .time)
                                        .font(AnixartFont.small)
                                        .foregroundColor(AnixartColor.textSecondary)
                                }

                                Text(entry.url)
                                    .font(AnixartFont.small)
                                    .foregroundColor(AnixartColor.textSecondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)

                                if !entry.body.isEmpty {
                                    Text("Body: \(entry.body)")
                                        .font(AnixartFont.small)
                                        .foregroundColor(AnixartColor.textPrimary)
                                        .lineLimit(2)
                                }

                                if !entry.response.isEmpty {
                                    Text("Resp: \(entry.response.prefix(120))")
                                        .font(AnixartFont.small)
                                        .foregroundColor(AnixartColor.textSecondary)
                                        .lineLimit(3)
                                }

                                if let error = entry.error {
                                    Text("Error: \(error)")
                                        .font(AnixartFont.small)
                                        .foregroundColor(AnixartColor.accent)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .listRowBackground(AnixartColor.background)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .background(AnixartColor.background)
            }
        }
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Копировать все") {
                        UIPasteboard.general.string = allLogsText()
                    }
                    Button("Очистить") {
                        logger.clear()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(AnixartColor.accent)
                }
            }
        }
        .sheet(item: $selectedEntry) { entry in
            DebugEntryDetail(entry: entry)
        }
    }

    private func allLogsText() -> String {
        logger.entries.map { entry in
            let time = entry.timestamp.formatted(date: .omitted, time: .shortened)
            return """
            [\(time)] \(entry.method) \(entry.url)
            Status: \(statusText(entry.status))
            Body: \(entry.body)
            Response: \(entry.response)
            Error: \(entry.error ?? "—")
            ---
            """
        }.joined(separator: "\n")
    }

    private func statusText(_ status: Int) -> String {
        if status == -1 { return "APIErr" }
        if status == -2 { return "Decode" }
        if status == -3 { return "Network" }
        return "\(status)"
    }

    private func statusColor(_ status: Int) -> Color {
        if status >= 200 && status < 300 { return AnixartColor.green }
        if status >= 400 { return AnixartColor.accent }
        if status < 0 { return AnixartColor.yellow }
        return AnixartColor.textSecondary
    }
}

struct DebugEntryDetail: View {
    let entry: APILogger.LogEntry

    var body: some View {
        NavigationStack {
            ZStack {
                AnixartColor.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            Text("URL").font(AnixartFont.caption).foregroundColor(AnixartColor.textSecondary)
                            Text(entry.url)
                                .font(AnixartFont.body)
                                .foregroundColor(AnixartColor.textPrimary)
                                .textSelection(.enabled)
                        }

                        Group {
                            Text("Status").font(AnixartFont.caption).foregroundColor(AnixartColor.textSecondary)
                            Text("\(entry.status)")
                                .font(AnixartFont.body)
                                .foregroundColor(entry.status >= 200 && entry.status < 300 ? AnixartColor.green : AnixartColor.accent)
                        }

                        if !entry.body.isEmpty {
                            Group {
                                Text("Request Body").font(AnixartFont.caption).foregroundColor(AnixartColor.textSecondary)
                                Text(entry.body)
                                    .font(AnixartFont.small)
                                    .foregroundColor(AnixartColor.textPrimary)
                                    .textSelection(.enabled)
                            }
                        }

                        if !entry.response.isEmpty {
                            Group {
                                Text("Response").font(AnixartFont.caption).foregroundColor(AnixartColor.textSecondary)
                                Text(entry.response)
                                    .font(AnixartFont.small)
                                    .foregroundColor(AnixartColor.textSecondary)
                                    .textSelection(.enabled)
                            }
                        }

                        if let error = entry.error {
                            Group {
                                Text("Error").font(AnixartFont.caption).foregroundColor(AnixartColor.textSecondary)
                                Text(error)
                                    .font(AnixartFont.body)
                                    .foregroundColor(AnixartColor.accent)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Детали запроса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AnixartColor.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Копировать") {
                        UIPasteboard.general.string = """
                        \(entry.method) \(entry.url)
                        Status: \(entry.status)
                        Body: \(entry.body)
                        Response: \(entry.response)
                        Error: \(entry.error ?? "—")
                        """
                    }
                    .foregroundColor(AnixartColor.accent)
                }
            }
        }
    }
}
