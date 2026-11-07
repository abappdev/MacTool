import SwiftUI

@main
struct MacToolApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        MenuBarExtra {
            TrayMenuView(environment: environment)
        } label: {
            TrayProgressIcon(cursorMovement: environment.cursorMovement)
        }
        .menuBarExtraStyle(.menu)

        Window("MacTool Settings", id: "settings") {
            SettingsRootView(environment: environment)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 720, height: 480)
    }
}
