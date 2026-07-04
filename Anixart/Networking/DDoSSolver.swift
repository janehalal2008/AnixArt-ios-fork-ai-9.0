import Foundation
import WebKit

actor DDoSSolver {
    static let shared = DDoSSolver()
    private var isReady = false

    func initialize() async {
        guard !isReady else { return }
        await solveChallenge()
        isReady = true
    }

    func solveChallenge() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                let config = WKWebViewConfiguration()
                config.websiteDataStore = WKWebsiteDataStore.default()
                let webView = WKWebView(frame: .zero, configuration: config)

                webView.load(URLRequest(url: URL(string: "https://api-s.anixsekai.com/")!))
                var checked = false

                webView.isHidden = true

                let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                    webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                        let hasGuardCookie = cookies.contains { $0.name == "__ddg1_" || $0.name == "__ddg8_" }
                        if hasGuardCookie && !checked {
                            checked = true
                            let cookieStore = HTTPCookieStorage.shared
                            for cookie in cookies {
                                cookieStore.setCookie(cookie)
                            }
                            print("[DDoSSolver] Cookies obtained: \(cookies.count)")
                            timer.invalidate()
                            continuation.resume()
                        }
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    if !checked {
                        timer.invalidate()
                        print("[DDoSSolver] Timeout, continuing without DDoS cookies")
                        continuation.resume()
                    }
                }
            }
        }
    }
}
