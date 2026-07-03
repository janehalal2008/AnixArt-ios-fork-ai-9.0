import SwiftUI
import AVKit
import WebKit

struct PlayerView: View {
    let episode: Episode
    let source: Source?
    let releaseId: Int

    @State private var player: AVPlayer?
    @State private var isLandscape = false
    @State private var isLoading = true
    @State private var error: String?

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ZStack {
                    Color.black

                    if let error {
                        VStack(spacing: 12) {
                            Text(error)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            if source?.hosting?.lowercased() == "kodik" || source?.hosting?.lowercased() == "iframe" {
                                WebPlayerView(url: source?.url)
                                    .frame(height: isLandscape ? geo.size.height : geo.size.width * 9/16)
                            }
                        }
                    } else if isLoading {
                        ProgressView()
                            .tint(.white)
                    } else if let player {
                        VideoPlayer(player: player)
                            .frame(height: isLandscape ? geo.size.height : geo.size.width * 9/16)
                    } else if source?.hosting?.lowercased() == "kodik" ||
                                source?.hosting?.lowercased() == "iframe" ||
                                source?.hosting?.lowercased() == "youtube" {
                        WebPlayerView(url: source?.url)
                            .frame(height: isLandscape ? geo.size.height : geo.size.width * 9/16)
                    }
                }
                .frame(height: isLandscape ? geo.size.height : geo.size.width * 9/16)

                if !isLandscape {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Эпизод \(episode.position): \(episode.name)")
                                .font(.headline)

                            if let hosting = source?.hosting {
                                Text("Хостинг: \(hosting)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            if let url = source?.url {
                                Text("URL: \(url)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("\(episode.position) серия")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadVideo() }
        .onRotate { newOrientation in
            isLandscape = newOrientation.isLandscape
        }
    }

    func loadVideo() async {
        guard let source else { isLoading = false; return }

        let hosting = source.hosting?.lowercased() ?? ""

        if hosting.contains("kodik") || hosting.contains("iframe") || hosting.contains("youtube") {
            isLoading = false
            return
        }

        guard let urlString = source.url, let url = URL(string: urlString) else {
            error = "Неверный URL видео"
            isLoading = false
            return
        }

        if urlString.hasSuffix(".m3u8") || urlString.hasSuffix(".mp4") {
            player = AVPlayer(url: url)
            player?.play()
            isLoading = false
        } else {
            isLoading = false
        }
    }
}

struct WebPlayerView: UIViewRepresentable {
    let url: String?

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = true
        if let url, let urlObj = URL(string: url) {
            webView.load(URLRequest(url: urlObj))
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationModifier(action: action))
    }
}

struct DeviceRotationModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}
