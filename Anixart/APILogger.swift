import Foundation
import SwiftUI

@MainActor
class APILogger: ObservableObject {
    static let shared = APILogger()

    @Published var entries: [LogEntry] = []
    private let maxEntries = 50

    struct LogEntry: Identifiable {
        let id = UUID()
        let timestamp: Date
        let method: String
        let url: String
        let status: Int
        let body: String
        let response: String
        let error: String?
    }

    private init() {}

    func log(method: String, url: String, status: Int, body: String = "", response: String = "", error: String? = nil) {
        let entry = LogEntry(
            timestamp: Date(),
            method: method,
            url: url,
            status: status,
            body: body,
            response: response.prefix(500).description,
            error: error
        )
        entries.insert(entry, at: 0)
        if entries.count > maxEntries {
            entries.removeLast()
        }
    }

    func clear() {
        entries.removeAll()
    }
}
