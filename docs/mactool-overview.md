# MacTool overview

**Path:** `/Users/ab/DeveloperStudio/MacTool`  
**Repo:** https://github.com/abappdev/MacTool · **Release:** v1.0.0  
**Kind:** macOS menu-bar (`LSUIElement`) utility — **Cursor Movement**.

## What it does

Posts tiny **1px** synthetic cursor movements on a chosen interval. Accessibility is required for posting mouse events.

## Tray menu

- **Cursor Movement** → Off · 30 sec · 1 · 2 · 5 · 10 min (persisted)
- **Settings…** → sidebar with **Cursor Movement** and **Permissions**
- **Open at Login**
- **Quit**

## How to run

```bash
open /Users/ab/DeveloperStudio/MacTool/MacTool.xcodeproj
```

Run the **MacTool** scheme. No Dock icon — use the `cursorarrow.click.2` SF Symbol tray icon.

## Permissions to expect

1. **Accessibility** (required) — first time you pick an interval or tap Request Access.
2. **Login Items** (optional) — when enabling Open at Login.
3. **Input Monitoring** — not required by MacTool; mentioned for IT policy only.

## Docs in repo

- [README.md](../README.md) — build / run / TCC
- [architecture.md](architecture.md) — modules, entitlements, App Store notes

## Open questions

1. Bundle ID is `in.abappdev.MacTool` (test target: `in.abappdev.MacToolTests`).
2. Menu bar uses system SF Symbol `cursorarrow.click.2` (no custom tray artwork). Finder/About App Icon is the teal cursor mark in `AppIcon.appiconset`.
3. GitHub remote — none yet; local git only until a remote is created.
4. Confirm whether a larger nudge or a click is needed in locked-screen scenarios (current design: 1px move only).
