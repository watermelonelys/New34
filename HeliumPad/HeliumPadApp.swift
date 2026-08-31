import SwiftUI

@main
struct HeliumPadApp: App {
    var body: some Scene {
        WindowGroup {
            BrowserView()
                .preferredColorScheme(.none)
        }
    }
}
