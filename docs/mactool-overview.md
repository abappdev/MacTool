# MacTool overview

**Path:** `/Users/ab/DeveloperStudio/MacTool`  
**Kind:** macOS menu-bar (`LSUIElement`) utility — first release feature **Cursor Movement / Don’t Make Mac Idle**.

## What it does

Posts tiny **1px** synthetic mouse moves on a chosen interval so:

- Corporate apps (e.g. **Microsoft Teams**) treat the user as active.
- **AI-agent** workflows are less likely to hit sleep / idle lock while unattended.

## Tray menu

- **Cursor Movement** → Off · 30 sec · 1 · 2 · 5 · 10 min (persisted)
- **Settings…** → sidebar with **Cursor Movement** and **Permissions** (chubby mouse mascot)
- **Open at Login**
- **Quit**

## How to run

```bash
open /Users/ab/DeveloperStudio/MacTool/MacTool.xcodeproj
```

Run the **MacTool** scheme. No Dock icon — use the chubby mouse tray icon (`MenuBarIcon` template).

## Permissions to expect

1. **Accessibility** (required) — first time you pick an interval or tap Request Access.
2. **Login Items** (optional) — when enabling Open at Login.
3. **Input Monitoring** — not required by MacTool; mentioned for IT policy only.

## Docs in repo

- [README.md](../README.md) — build / run / TCC
- [architecture.md](architecture.md) — modules, entitlements, App Store notes

## Open questions

1. Bundle ID is `in.abappdev.MacTool` (test target: `in.abappdev.MacToolTests`).
2. Chubby mouse mascot: color `Mascot` / AppIcon + template `MenuBarIcon` (see `Design/` and `Assets.xcassets`).
3. GitHub remote — none yet; local git only until a remote is created.
4. Confirm whether Teams (or other target apps) need a larger nudge or a click in locked-screen scenarios (current design: 1px move only).
