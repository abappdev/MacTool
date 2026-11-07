import SwiftUI

/// Cursor Movement settings pane — interval control + purpose copy.
struct CursorMovementSettingsView: View {
    @ObservedObject var environment: AppEnvironment
    @ObservedObject private var cursorMovement: CursorMovementService

    init(environment: AppEnvironment) {
        self.environment = environment
        self._cursorMovement = ObservedObject(wrappedValue: environment.cursorMovement)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Cursor Movement")
                        .font(.title2.weight(.semibold))
                    Text(
                        """
                        Posts tiny (1px) synthetic cursor movements on a chosen interval \
                        via the Accessibility APIs.
                        """
                    )
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }

                GroupBox("Interval") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Move cursor", selection: Binding(
                            get: { cursorMovement.interval },
                            set: { newValue in
                                cursorMovement.setInterval(newValue)
                                if newValue.isActive {
                                    environment.permissions.requestAccessibilityPromptIfNeeded()
                                }
                            }
                        )) {
                            ForEach(CursorMovementInterval.allCases) { option in
                                Text(option.title).tag(option)
                            }
                        }
                        .pickerStyle(.radioGroup)

                        Text(statusLine)
                            .font(.callout)
                            .foregroundStyle(cursorMovement.interval.isActive ? .primary : .secondary)
                    }
                    .padding(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Tip") {
                    Text(
                        """
                        Accessibility permission is required for nudges to work. \
                        Open the Permissions tab if Cursor Movement seems inactive.
                        """
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .padding(4)
                }
            }
            .padding(24)
        }
        .navigationTitle("Cursor Movement")
    }

    private var statusLine: String {
        switch cursorMovement.interval {
        case .off:
            return "Cursor Movement is off."
        default:
            return "Nudging every \(cursorMovement.interval.title.lowercased().replacingOccurrences(of: "every ", with: ""))."
        }
    }
}
