import Foundation

/// Composition root — wires concrete services for production.
@MainActor
final class AppEnvironment: ObservableObject {
    let settings: SettingsStoring
    let cursorMovement: CursorMovementService
    let permissions: PermissionsChecking
    let loginItem: LoginItemManaging

    init(
        settings: SettingsStoring = UserDefaultsSettingsStore(),
        permissions: PermissionsChecking = PermissionsService(),
        nudger: MouseNudgePerforming = CGEventMouseNudger()
    ) {
        self.settings = settings
        self.permissions = permissions
        let login = LoginItemService(settings: settings)
        login.syncFromSystem()
        self.loginItem = login
        self.cursorMovement = CursorMovementService(settings: settings, nudger: nudger)
    }
}
