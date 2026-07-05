import Foundation
import WebKit

actor DDoSSolver: NSObject {
    static let shared = DDoSSolver()
    private var webView: WKWebView?
    private var continuation: CheckedContinuation<Void, Error>?
    private var isReady = false

    func initialize() async throws {
        guard !isReady else { return }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            self.continuation = cont
            DispatchQueue.main.async {
                let config = WKWebViewConfiguration()
                config.websiteDataStore = WKWebsiteDataStore.default()
                self.webView = WKWebView(frame: .zero, configuration: config)
                self.webView?.navigationDelegate = self
                self.webView?.load(URLRequest(url: URL(string: "https://api-s.anixsekai.com/")!))
                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                    if !self.isReady {
                        self.copyCookies()
                        cont.resume()
                    }
                }
            }
        }
        isReady = true
    }

    private func copyCookies() {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        DispatchQueue.main.async {
            self.webView?.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.wait()
    }
}

extension DDoSSolver: WKNavigationDelegate {
    nonisolated func webView(_ wv: WKWebView, didFinish navigation: WKNavigation!) {
        Task { await self.onPageLoaded() }
    }

    private func onPageLoaded() {
        copyCookies()
        continuation?.resume()
        continuation = nil
    }
}
