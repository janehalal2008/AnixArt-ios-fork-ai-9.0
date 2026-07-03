import SwiftUI

struct CachedImage: View {
    let url: String?

    var body: some View {
        AsyncImage(url: url.flatMap { URL(string: $0) }) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Color(.systemGray5)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    )
            case .empty:
                Color(.systemGray5)
                    .overlay(
                        ProgressView()
                    )
            @unknown default:
                Color(.systemGray5)
            }
        }
    }
}
