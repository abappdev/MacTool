import SwiftUI

enum SettingsTab: String, Hashable, CaseIterable, Identifiable {
    case cursorMovement
    case permissions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cursorMovement: return "Cursor Movement"
        case .permissions: return "Permissions"
        }
    }

    var systemImage: String {
        switch self {
        case .cursorMovement: return "cursorarrow.motionlines"
        case .permissions: return "lock.shield"
        }
    }
}

/// Settings window with sidebar: Cursor Movement | Permissions.
struct SettingsRootView: View {
    @ObservedObject var environment: AppEnvironment
    @State private var selection: SettingsTab? = .cursorMovement

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                mascotHeader
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                List(selection: $selection) {
                    ForEach(SettingsTab.allCases) { tab in
                        Label(tab.title, systemImage: tab.systemImage)
                            .tag(tab)
                    }
                }
                .listStyle(.sidebar)
            }
            .navigationSplitViewColumnWidth(min: 170, ideal: 190, max: 240)
        } detail: {
            Group {
                switch selection ?? .cursorMovement {
                case .cursorMovement:
                    CursorMovementSettingsView(environment: environment)
                case .permissions:
                    PermissionsSettingsView(environment: environment)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(minWidth: 640, minHeight: 440)
        .navigationTitle("MacTool Settings")
    }

    private var mascotHeader: some View {
        VStack(spacing: 6) {
            Image("Mascot")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 72, height: 72)
                .accessibilityLabel("MacTool mascot")

            Text("MacTool")
                .font(.headline)
            Text("Don’t make Mac idle")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
