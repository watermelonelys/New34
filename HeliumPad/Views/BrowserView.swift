import SwiftUI

struct BrowserView: View {
    @State private var tabs: [Tab] = [Tab()]
    @State private var activeTabID: Tab.ID?
    @AppStorage("adBlockEnabled") private var adBlockEnabled: Bool = true

    private var activeTab: Tab? {
        tabs.first(where: { $0.id == activeTabID }) ?? tabs.first
    }

    var body: some View {
        VStack(spacing: 0) {
            TabBarView(
                tabs: $tabs,
                activeTabID: $activeTabID,
                onNewTab: newTab,
                onClose: closeTab
            )

            Divider()

            if let tab = activeTab {
                AddressBarView(tab: tab, adBlockEnabled: $adBlockEnabled, onNewTab: newTab)
                Divider()
                ZStack {
                    ForEach(tabs) { tab in
                        WebView(tab: tab, adBlockEnabled: adBlockEnabled)
                            .opacity(tab.id == activeTab?.id ? 1 : 0)
                            .allowsHitTesting(tab.id == activeTab?.id)
                    }
                }
            } else {
                Spacer()
                Text("No tabs open")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .onAppear {
            if activeTabID == nil {
                activeTabID = tabs.first?.id
            }
        }
        .background(Color(.systemBackground))
    }

    private func newTab() {
        let tab = Tab()
        tabs.append(tab)
        activeTabID = tab.id
    }

    private func closeTab(_ tab: Tab) {
        guard let index = tabs.firstIndex(of: tab) else { return }
        tabs.remove(at: index)

        if tabs.isEmpty {
            let fresh = Tab()
            tabs = [fresh]
            activeTabID = fresh.id
        } else if activeTabID == tab.id {
            let newIndex = min(index, tabs.count - 1)
            activeTabID = tabs[newIndex].id
        }
    }
}
