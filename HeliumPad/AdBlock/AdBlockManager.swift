import Foundation
import WebKit

/// Compiles the bundled ad/tracker block list into a WKContentRuleList
/// and applies it to a web view's user content controller, mirroring
/// Helium's "privacy-first, unbiased ad-blocking" approach.
final class AdBlockManager {
    static let shared = AdBlockManager()

    private let identifier = "com.helium.ipad.blocklist"
    private var compiledList: WKContentRuleList?
    private var isCompiling = false
    private var pendingCompletions: [(WKContentRuleList?) -> Void] = []

    private init() {}

    func compileIfNeeded(completion: @escaping (WKContentRuleList?) -> Void) {
        if let compiledList {
            completion(compiledList)
            return
        }

        pendingCompletions.append(completion)
        guard !isCompiling else { return }
        isCompiling = true

        guard
            let url = Bundle.main.url(forResource: "blocklist", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let json = String(data: data, encoding: .utf8)
        else {
            finish(with: nil)
            return
        }

        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: identifier,
            encodedContentRuleList: json
        ) { [weak self] list, error in
            if let error {
                print("HeliumPad AdBlock compile error: \(error)")
            }
            self?.finish(with: list)
        }
    }

    private func finish(with list: WKContentRuleList?) {
        compiledList = list
        isCompiling = false
        let callbacks = pendingCompletions
        pendingCompletions.removeAll()
        callbacks.forEach { $0(list) }
    }

    /// Applies (or removes) the block list on the given web view.
    func apply(to webView: WKWebView, enabled: Bool) {
        let controller = webView.configuration.userContentController
        controller.removeAllContentRuleLists()
        guard enabled else { return }

        compileIfNeeded { list in
            guard let list else { return }
            DispatchQueue.main.async {
                controller.add(list)
            }
        }
    }
}
