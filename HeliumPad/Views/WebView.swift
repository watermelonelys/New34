import SwiftUI
import WebKit
import Combine

struct WebView: UIViewRepresentable {
    @ObservedObject var tab: Tab
    var adBlockEnabled: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(tab: tab)
    }

    func makeUIView(context: Context) -> WKWebView {
        tab.webView.navigationDelegate = context.coordinator
        tab.webView.uiDelegate = context.coordinator
        tab.webView.addObserver(context.coordinator, forKeyPath: "estimatedProgress", options: .new, context: nil)
        tab.webView.addObserver(context.coordinator, forKeyPath: "title", options: .new, context: nil)
        tab.webView.addObserver(context.coordinator, forKeyPath: "canGoBack", options: .new, context: nil)
        tab.webView.addObserver(context.coordinator, forKeyPath: "canGoForward", options: .new, context: nil)
        AdBlockManager.shared.apply(to: tab.webView, enabled: adBlockEnabled)
        return tab.webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        AdBlockManager.shared.apply(to: tab.webView, enabled: adBlockEnabled)
    }

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.removeObserver(coordinator, forKeyPath: "estimatedProgress")
        uiView.removeObserver(coordinator, forKeyPath: "title")
        uiView.removeObserver(coordinator, forKeyPath: "canGoBack")
        uiView.removeObserver(coordinator, forKeyPath: "canGoForward")
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let tab: Tab

        init(tab: Tab) {
            self.tab = tab
        }

        override func observeValue(
            forKeyPath keyPath: String?,
            of object: Any?,
            change: [NSKeyValueChangeKey: Any]?,
            context: UnsafeMutableRawPointer?
        ) {
            guard let webView = object as? WKWebView else { return }
            switch keyPath {
            case "estimatedProgress":
                tab.estimatedProgress = webView.estimatedProgress
            case "title":
                tab.title = webView.title?.isEmpty == false ? webView.title! : tab.urlString
            case "canGoBack":
                tab.canGoBack = webView.canGoBack
            case "canGoForward":
                tab.canGoForward = webView.canGoForward
            default:
                break
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            tab.isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            tab.isLoading = false
            if let url = webView.url {
                tab.urlString = url.absoluteString
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            tab.isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            tab.isLoading = false
        }

        // Open target="_blank" links in the same tab instead of dropping them.
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
