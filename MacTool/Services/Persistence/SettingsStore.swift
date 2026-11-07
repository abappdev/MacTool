import Foundation

/// Persists user preferences across launches.
/// Protocol seam enables unit tests without touching UserDefaults.
protocol SettingsStoring: AnyObject {
    var cursorMovementIntervalRaw: String { get set }
    var openAtLoginEnabled: Bool { get set }
}

enum SettingsKey {
    static let cursorMovementInterval = "cursorMovementInterval"
    static let openAtLogin = "openAtLoginEnabled"
}

final class UserDefaultsSettingsStore: SettingsStoring {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var cursorMovementIntervalRaw: String {
        get {
            defaults.string(forKey: SettingsKey.cursorMovementInterval)
                ?? CursorMovementInterval.off.rawValue
        }
        set {
            defaults.set(newValue, forKey: SettingsKey.cursorMovementInterval)
        }
    }

    var openAtLoginEnabled: Bool {
        get { defaults.bool(forKey: SettingsKey.openAtLogin) }
        set { defaults.set(newValue, forKey: SettingsKey.openAtLogin) }
    }
}
