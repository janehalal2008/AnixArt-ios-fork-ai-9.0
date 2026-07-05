import Foundation
import WebKit

@MainActor
class DDoSSolver: NSObject {
    static let shared = DDoSSolver()
    private var webView: WKWebView?
    private var continuation: CheckedContinuation<Void, Error>?
    private(set) var isReady = false

    func initialize() async throws {
        guard !isReady else { return }
        try await withCheckedThrowingContinuation { cont in
            self.continuation = cont
            let config = WKWebViewConfiguration()
            config.websiteDataStore = WKWebsiteDataStore.default()
            let webView = WKWebView(frame: .zero, configuration: config)
            webView.navigationDelegate = self
            self.webView = webView
            webView.load(URLRequest(url: URL(string: "https://api-s.anixsekai.com/")!))
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                if !self.isReady {
                    self.finish()
                }
            }
        }
        isReady = true
    }

    private func finish() {
        webView?.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
        continuation?.resume()
        continuation = nil
    }
}

extension DDoSSolver: WKNavigationDelegate {
    func webView(_ wv: WKWebView, didFinish navigation: WKNavigation!) {
        finish()
    }
}
