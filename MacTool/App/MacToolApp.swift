import SwiftUI

@main
struct MacToolApp: App {
    @StateObject private var environment = AppEnvironment()

    var body: some Scene {
        MenuBarExtra("MacTool", systemImage: "cursorarrow.click.2") {
            TrayMenuView(environment: environment)
        }
        .menuBarExtraStyle(.menu)

        Window("MacTool Permissions", id: "permissions") {
            PermissionsView(environment: environment)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 480, height: 520)
    }
}
