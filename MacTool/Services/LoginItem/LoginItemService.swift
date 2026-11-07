import Foundation
import ServiceManagement

protocol LoginItemManaging: AnyObject {
    var isEnabled: Bool { get }
    @discardableResult
    func setEnabled(_ enabled: Bool) throws -> Bool
}

/// Uses `SMAppService` (macOS 13+) for Open at Login.
final class LoginItemService: LoginItemManaging {
    private let settings: SettingsStoring

    init(settings: SettingsStoring) {
        self.settings = settings
    }

    var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return settings.openAtLoginEnabled
    }

    @discardableResult
    func setEnabled(_ enabled: Bool) throws -> Bool {
        if #available(macOS 13.0, *) {
            let service = SMAppService.mainApp
            if enabled {
                try service.register()
            } else {
                try service.unregister()
            }
            settings.openAtLoginEnabled = (service.status == .enabled)
            return service.status == .enabled
        }

        settings.openAtLoginEnabled = enabled
        return enabled
    }

    /// Reconcile persisted preference with the system Login Item state on launch.
    func syncFromSystem() {
        if #available(macOS 13.0, *) {
            settings.openAtLoginEnabled = (SMAppService.mainApp.status == .enabled)
        }
    }
}
