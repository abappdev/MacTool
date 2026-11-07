import SwiftUI

/// Explains why MacTool needs Accessibility and how to enable Open at Login.
struct PermissionsView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var status: PermissionStatus
    @State private var openAtLogin: Bool
    @State private var loginError: String?

    init(environment: AppEnvironment) {
        self.environment = environment
        _status = State(initialValue: environment.permissions.currentStatus())
        _openAtLogin = State(initialValue: environment.loginItem.isEnabled)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                purposeSection
                accessibilitySection
                inputMonitoringSection
                loginSection
                refreshRow
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 440, minHeight: 380)
        .navigationTitle("Permissions")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MacTool Permissions")
                .font(.title2.weight(.semibold))
            Text("Grant the access below so Cursor Movement can keep your Mac from looking idle.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var purposeSection: some View {
        GroupBox("Why this is needed") {
            Text(
                """
                MacTool’s Cursor Movement feature posts tiny (1px) synthetic mouse moves \
                so corporate apps such as Microsoft Teams treat you as active, and so \
                AI-agent workflows keep the Mac awake instead of sleeping or locking.
                """
            )
            .font(.callout)
            .fixedSize(horizontal: false, vertical: true)
            .padding(4)
        }
    }

    private var accessibilitySection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Accessibility", systemImage: "accessibility")
                        .font(.headline)
                    Spacer()
                    statusBadge(granted: status.accessibilityTrusted)
                }

                Text(
                    """
                    Required to post synthetic mouse events. Without it, Cursor Movement \
                    cannot nudge the pointer.
                    """
                )
                .font(.callout)
                .foregroundStyle(.secondary)

                Text(
                    """
                    How to enable:
                    1. Click “Open Accessibility Settings”.
                    2. Unlock if needed, find MacTool in the list, and turn it on.
                    3. If MacTool is missing, click “+” and add the app, or click \
                    “Request Access…” below first.
                    4. Return here and click Refresh.
                    """
                )
                .font(.callout)

                HStack {
                    Button("Request Access…") {
                        environment.permissions.requestAccessibilityPromptIfNeeded()
                        refresh()
                    }
                    Button("Open Accessibility Settings") {
                        environment.permissions.openAccessibilitySettings()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(4)
        } label: {
            Text("Accessibility")
        }
    }

    private var inputMonitoringSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label("Input Monitoring", systemImage: "keyboard")
                    .font(.headline)

                Text(
                    """
                    MacTool does not monitor your keystrokes or mouse input—it only \
                    posts tiny outbound mouse moves. Some IT policies still list Input \
                    Monitoring alongside Accessibility; open the pane below if your org \
                    requires it.
                    """
                )
                .font(.callout)
                .foregroundStyle(.secondary)

                Button("Open Input Monitoring Settings") {
                    environment.permissions.openInputMonitoringSettings()
                }
            }
            .padding(4)
        } label: {
            Text("Input Monitoring (optional)")
        }
    }

    private var loginSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Toggle("Open at Login", isOn: Binding(
                    get: { openAtLogin },
                    set: { newValue in
                        do {
                            openAtLogin = try environment.loginItem.setEnabled(newValue)
                            loginError = nil
                        } catch {
                            openAtLogin = environment.loginItem.isEnabled
                            loginError = error.localizedDescription
                        }
                    }
                ))

                Text("Start MacTool automatically when you log in to this Mac.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button("Open Login Items Settings") {
                    environment.permissions.openLoginItemsSettings()
                }

                if let loginError {
                    Text(loginError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(4)
        } label: {
            Text("Open at Login")
        }
    }

    private var refreshRow: some View {
        HStack {
            Button("Refresh Status") { refresh() }
            Spacer()
            Text(status.allGranted ? "Ready for Cursor Movement" : "Action needed")
                .font(.caption)
                .foregroundStyle(status.allGranted ? .green : .orange)
        }
    }

    private func statusBadge(granted: Bool) -> some View {
        Text(granted ? "Granted" : "Not granted")
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(granted ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func refresh() {
        status = environment.permissions.currentStatus()
        openAtLogin = environment.loginItem.isEnabled
    }
}
