import Foundation

struct Config: Codable {
    let apiBaseURL: String
    let staticDomain: String
    let editorUrl: String
    let kodikVideoLinksUrl: String
    let kodikAdIframeUrl: String
    let iframeEmbedUrl: String
    let torlookUrl: String
    let sibnetUserAgent: String
    let sibnetRandUserAgent: Bool
    let codecProfile: String
    let authAvailable: Bool
    let googleAuth: Bool
    let vkAuth: Bool
    let telegramAuth: Bool
    let altConnectionMode: Bool

    static let `default` = Config(
        apiBaseURL: "https://api-s.anixsekai.com/",
        staticDomain: "",
        editorUrl: "",
        kodikVideoLinksUrl: "",
        kodikAdIframeUrl: "",
        iframeEmbedUrl: "",
        torlookUrl: "",
        sibnetUserAgent: "",
        sibnetRandUserAgent: false,
        codecProfile: "",
        authAvailable: true,
        googleAuth: true,
        vkAuth: true,
        telegramAuth: true,
        altConnectionMode: false
    )
}
