import Foundation
import WebKit
import SwiftUI

@MainActor
class DDoSSolver: NSObject {
    static let shared = DDoSSolver()
    private var webView: WKWebView?
    private var continuation: CheckedContinuation<Void, Error>?
    private(set) var isReady = false

    func initialize() async throws {
        guard !isReady else {
            await APILogger.shared.log(method: "DDoS", url: "DDoSSolver already ready", status: 200, response: "cached")
            return
        }
        await APILogger.shared.log(method: "DDoS", url: "https://api-s.anixsekai.com/", status: 0, response: "initializing webview...")
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
            let cookieNames = cookies.map { "\($0.name)=\($0.value.prefix(20))" }.joined(separator: "; ")
            Task { @MainActor in
                await APILogger.shared.log(method: "DDoS", url: "https://api-s.anixsekai.com/", status: 200, response: "cookies: \(cookieNames)")
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

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            await APILogger.shared.log(method: "DDoS", url: "https://api-s.anixsekai.com/", status: -3, error: error.localizedDescription)
        }
        finish()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Task { @MainActor in
            await APILogger.shared.log(method: "DDoS", url: "https://api-s.anixsekai.com/", status: -3, error: error.localizedDescription)
        }
        finish()
    }
}
