# MacTool architecture

## Goals

- Menu-bar-only agent app (`LSUIElement`).
- Production-shaped modules with protocol seams for tests.
- Public APIs only (`CGEvent`, `AXIsProcessTrusted*`, `SMAppService`).
- Sandbox-aware design: document App Store limits rather than pretending sandbox works for synthetic input.

## Module map

```
MacTool/
  App/                 Composition root + SwiftUI @main (MenuBarExtra)
  Menu/                Tray menu + Settings window (Cursor Movement | Permissions)
  Services/
    CursorMovement/    Interval model, scheduler, CGEvent nudger
    Permissions/       TCC status + System Settings deep links
    LoginItem/         SMAppService Open at Login
    Persistence/       UserDefaults settings store
```

| Module | Responsibility | Test seam |
|---|---|---|
| `AppEnvironment` | Wires concrete services | Inject fakes in tests |
| `CursorMovementService` | Main-actor `Timer` scheduling + cycle progress for tray ring; cancel on Off/Quit | `MouseNudgePerforming`, `SettingsStoring` |
| `TrayProgressIcon` | Menu-bar label: SF Symbol + countdown ring via `TimelineView` | Observes `CursorMovementService` |
| `CGEventMouseNudger` | ±1px move via `CGEvent.post(tap: .cghidEventTap)` | Protocol `MouseNudgePerforming` |
| `PermissionsService` | `AXIsProcessTrusted` / prompt / open prefs URLs | `PermissionsChecking` |
| `LoginItemService` | `SMAppService.mainApp` register/unregister | `LoginItemManaging` |
| `UserDefaultsSettingsStore` | Persist interval + login preference | `SettingsStoring` |

## Scheduling

- Timers are created on the main run loop (`.common`) from `@MainActor` `CursorMovementService`.
- Tolerance ≈ 10% of the period (capped at 1s) to reduce energy impact.
- `cancelScheduling()` invalidates without clearing the persisted interval (used on Quit).
- `stop()` / selecting **Off** invalidates and persists `.off`.

## Entitlements & TCC

- `com.apple.security.app-sandbox` = **false** (see entitlements comments).
- Hardened Runtime enabled for Release-style distribution readiness; local Debug may ad-hoc sign.
- Accessibility is the hard requirement for nudges. Input Monitoring is documented as optional.

## App Store readiness checklist

- [x] No private APIs
- [x] Privacy usage string for Accessibility
- [x] Clear entitlement comments for reviewers / future you
- [x] Menu-bar tray uses system SF Symbol (`cursorarrow.click.2`); App Icon set shipped
- [x] Signing Team `44GWMTNP57` + Developer ID release via `scripts/release.sh`
- [x] Distribute outside App Store (GitHub Releases); sandbox remains off for synthetic input

## SOLID notes

- **S** — one service per concern (movement, permissions, login, persistence).
- **O** — new intervals extend `CursorMovementInterval` without changing the scheduler core.
- **L/I** — callers depend on narrow protocols (`MouseNudgePerforming`, etc.).
- **D** — `AppEnvironment` / `CursorMovementService` take abstractions; production types are defaults.
