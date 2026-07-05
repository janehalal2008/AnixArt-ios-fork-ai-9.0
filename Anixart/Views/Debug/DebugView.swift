import SwiftUI

struct DebugView: View {
    @StateObject private var logger = APILogger.shared

    var body: some View {
        ZStack {
            AnixartColor.background.ignoresSafeArea()

            List {
                ForEach(logger.entries) { entry in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(entry.method)
                                .font(AnixartFont.caption)
                                .fontWeight(.bold)
                                .foregroundColor(statusColor(entry.status))
                            Text("\(entry.status)")
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

                        if !entry.body.isEmpty {
                            Text("Body: \(entry.body)")
                                .font(AnixartFont.small)
                                .foregroundColor(AnixartColor.textPrimary)
                        }

                        if !entry.response.isEmpty {
                            Text("Resp: \(entry.response)")
                                .font(AnixartFont.small)
                                .foregroundColor(AnixartColor.textSecondary)
                                .lineLimit(4)
                        }

                        if let error = entry.error {
                            Text("Error: \(error)")
                                .font(AnixartFont.small)
                                .foregroundColor(AnixartColor.accent)
                        }
                    }
                    .padding(.vertical, 4)
                    .background(AnixartColor.background)
                }
            }
            .listStyle(.plain)
            .background(AnixartColor.background)
        }
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AnixartColor.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Очистить") {
                    logger.clear()
                }
                .foregroundColor(AnixartColor.accent)
            }
        }
    }

    private func statusColor(_ status: Int) -> Color {
        if status >= 200 && status < 300 { return AnixartColor.green }
        if status >= 400 { return AnixartColor.accent }
        if status < 0 { return AnixartColor.yellow }
        return AnixartColor.textSecondary
    }
}
