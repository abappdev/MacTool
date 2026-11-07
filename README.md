# MacTool

macOS **menu-bar** utility. First feature: **Cursor Movement** — schedules tiny (1px) synthetic cursor movements via Accessibility APIs.

## Requirements

- macOS 13+
- Xcode 15+ (built with Xcode 27 on this machine)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) only if you regenerate the project from `project.yml`

## Open & run

```bash
open /Users/ab/DeveloperStudio/MacTool/MacTool.xcodeproj
```

In Xcode: select the **MacTool** scheme → **My Mac** → Run (⌘R).

Or from the terminal:

```bash
cd /Users/ab/DeveloperStudio/MacTool
xcodebuild -scheme MacTool -configuration Debug -destination 'platform=macOS' build
open ~/Library/Developer/Xcode/DerivedData/MacTool-*/Build/Products/Debug/MacTool.app
```

The app is an `LSUIElement` (agent) app: **no Dock icon**. Look for the `cursorarrow.click.2` SF Symbol in the menu bar. The Finder/About **App Icon** is a teal cursor mark in `MacTool/Resources/Assets.xcassets/AppIcon.appiconset/` (regenerate with `scripts/generate_app_icon.py` if needed).

## Tray menu

1. **Cursor Movement** — Off | Every 30 sec | 1 min | 2 min | 5 min | 10 min  
   Selection persists across launches. Choosing an interval starts/reschedules a 1px nudge; **Off** stops it.
2. **Settings…** — sidebar window with **Cursor Movement** and **Permissions** tabs.
3. **Open at Login** — `SMAppService` toggle (also in Settings → Permissions).
4. **Quit MacTool**

## Permissions (TCC)

| Permission | Required? | Why |
|---|---|---|
| **Accessibility** | Yes | Required for posting synthetic `CGEvent` mouse events. |
| **Input Monitoring** | No (optional) | MacTool does not monitor input; listed for IT policy completeness. |
| **Login Items** | Optional | Open at Login via `SMAppService`. |

**Expected prompts**

1. On first active interval (or “Request Access…”): macOS Accessibility trust prompt.
2. Open at Login: may show a Login Items confirmation / appear under **System Settings → General → Login Items**.

**Manual path:** System Settings → Privacy & Security → Accessibility → enable **MacTool**.

Privacy usage string lives in `MacTool/Resources/Info.plist` (`NSAccessibilityUsageDescription`).

## Architecture

See [docs/architecture.md](docs/architecture.md).

## Tests

```bash
cd /Users/ab/DeveloperStudio/MacTool
xcodebuild -scheme MacTool -destination 'platform=macOS' test
```

## App Store / sandbox notes

Synthetic HID events that affect other apps generally require a **non-sandboxed** build plus Accessibility. Sandbox is **disabled** in `MacTool.entitlements` on purpose. Prefer **Developer ID** / direct distribution for this utility. Details in the architecture doc.

## Regenerate project

```bash
cd /Users/ab/DeveloperStudio/MacTool
xcodegen generate
```
