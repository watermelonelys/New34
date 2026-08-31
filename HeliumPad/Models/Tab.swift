import Foundation
import WebKit
import Combine

/// A single browser tab. Owns its own WKWebView instance so that
/// navigation state (back/forward stack, scroll position, etc.) is
/// preserved when switching between tabs.
final class Tab: ObservableObject, Identifiable, Equatable {
    let id = UUID()

    @Published var title: String = "New Tab"
    @Published var urlString: String = ""
    @Published var isLoading: Bool = false
    @Published var estimatedProgress: Double = 0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var favicon: URL?

    let webView: WKWebView

    init(startURL: URL? = URL(string: "https://www.google.com")) {
        let config = WKWebViewConfiguration()
        config.userContentController = WKUserContentController()
        config.websiteDataStore = .default()

        // Private browsing tabs use a non-persistent store instead.
        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true

        if let startURL {
            urlString = startURL.absoluteString
            webView.load(URLRequest(url: startURL))
        }
    }

    static func == (lhs: Tab, rhs: Tab) -> Bool {
        lhs.id == rhs.id
    }

    func load(_ input: String) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let url: URL?
        if let candidate = URL(string: trimmed),
           candidate.scheme != nil,
           trimmed.contains(".") || trimmed.contains("localhost") {
            url = candidate
        } else if trimmed.contains(" ") || !trimmed.contains(".") {
            // Looks like a search query rather than a URL.
            var comps = URLComponents(string: "https://duckduckgo.com/html/")
            comps?.queryItems = [URLQueryItem(name: "q", value: trimmed)]
            url = comps?.url
        } else {
            url = URL(string: "https://\(trimmed)")
        }

        if let url {
            urlString = url.absoluteString
            webView.load(URLRequest(url: url))
        }
    }

    func reload() { webView.reload() }
    func goBack() { webView.goBack() }
    func goForward() { webView.goForward() }
    func stop() { webView.stopLoading() }
}
