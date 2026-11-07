import SwiftUI

@main
struct MacToolApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        MenuBarExtra("MacTool", systemImage: "cursorarrow.click.2") {
            TrayMenuView(environment: environment)
        }
        .menuBarExtraStyle(.menu)

        Window("MacTool Settings", id: "settings") {
            SettingsRootView(environment: environment)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 720, height: 480)
    }
}
