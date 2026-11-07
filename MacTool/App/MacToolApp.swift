import SwiftUI

@main
struct MacToolApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        MenuBarExtra {
            TrayMenuView(environment: environment)
        } label: {
            // Template asset: chubby mouse silhouette, system-tinted for light/dark menu bar.
            Label("MacTool", image: "MenuBarIcon")
        }
        .menuBarExtraStyle(.menu)

        Window("MacTool Settings", id: "settings") {
            SettingsRootView(environment: environment)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 720, height: 480)
    }
}
