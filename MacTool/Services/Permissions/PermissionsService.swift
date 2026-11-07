import ApplicationServices
import AppKit
import Foundation

/// Describes MacTool permission state and how to grant access.
struct PermissionStatus: Equatable {
    let accessibilityTrusted: Bool

    var allGranted: Bool { accessibilityTrusted }
}

protocol PermissionsChecking: AnyObject {
    func currentStatus() -> PermissionStatus
    /// Prompts for Accessibility if not yet trusted (shows system dialog once).
    @discardableResult
    func requestAccessibilityPromptIfNeeded() -> Bool
    func openAccessibilitySettings()
    func openInputMonitoringSettings()
    func openLoginItemsSettings()
}

final class PermissionsService: PermissionsChecking {
    func currentStatus() -> PermissionStatus {
        PermissionStatus(
            accessibilityTrusted: AXIsProcessTrusted()
        )
    }

    @discardableResult
    func requestAccessibilityPromptIfNeeded() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func openAccessibilitySettings() {
        openURL("x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    }

    func openInputMonitoringSettings() {
        // Listed for completeness: MacTool posts events; it does not monitor them.
        // Some corporate policies still expect Input Monitoring to be reviewed.
        openURL("x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
    }

    func openLoginItemsSettings() {
        if #available(macOS 13.0, *) {
            openURL("x-apple.systempreferences:com.apple.LoginItems-Settings.extension")
        } else {
            openURL("x-apple.systempreferences:com.apple.preferences.users")
        }
    }

    private func openURL(_ string: String) {
        guard let url = URL(string: string) else { return }
        NSWorkspace.shared.open(url)
    }
}
