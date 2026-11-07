import AppKit
import SwiftUI

/// System tray (menu bar) content for MacTool.
struct TrayMenuView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var cursorMovement: CursorMovementService
    @Environment(\.openWindow) private var openWindow
    @State private var openAtLogin: Bool

    init(environment: AppEnvironment) {
        self.environment = environment
        self._cursorMovement = ObservedObject(wrappedValue: environment.cursorMovement)
        self._openAtLogin = State(initialValue: environment.loginItem.isEnabled)
    }

    var body: some View {
        Menu("Cursor Movement") {
            ForEach(CursorMovementInterval.allCases) { option in
                Button {
                    cursorMovement.setInterval(option)
                    if option.isActive {
                        environment.permissions.requestAccessibilityPromptIfNeeded()
                    }
                } label: {
                    if cursorMovement.interval == option {
                        Text(option.title)
                        Image(systemName: "checkmark")
                    } else {
                        Text(option.title)
                    }
                }
            }
        }

        Divider()

        Button("Settings…") {
            openWindow(id: "settings")
            NSApp.activate(ignoringOtherApps: true)
        }

        Toggle("Open at Login", isOn: Binding(
            get: { openAtLogin },
            set: { newValue in
                do {
                    openAtLogin = try environment.loginItem.setEnabled(newValue)
                } catch {
                    openAtLogin = environment.loginItem.isEnabled
                }
            }
        ))

        Divider()

        Button("Quit MacTool") {
            environment.cursorMovement.cancelScheduling()
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
