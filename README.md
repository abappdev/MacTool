# MacTool

macOS **menu-bar** utility. First feature: **Cursor Movement** — schedules tiny (1px) synthetic cursor movements via Accessibility APIs.

**Download:** [GitHub Releases](https://github.com/abappdev/MacTool/releases) · **Current:** v1.0.2  
**Bundle ID:** `in.abappdev.MacTool`

## Install (release build)

1. Download `MacTool-1.0.2.dmg` from [Releases](https://github.com/abappdev/MacTool/releases/latest)
2. Open the disk image → drag **MacTool** to **Applications**
3. Eject the DMG, open MacTool from Applications (right-click → **Open** if Gatekeeper warns)
4. Grant **Accessibility** when enabling Cursor Movement (Settings → Permissions)

```bash
codesign -dv --verbose=4 /Applications/MacTool.app
spctl --assess --type execute /Applications/MacTool.app
```

## Requirements

- macOS 13+
- Xcode 15+ (to build from source)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) to regenerate `MacTool.xcodeproj` from `project.yml`

## Open & run (debug)

```bash
open MacTool.xcodeproj
```

Or:

```bash
xcodebuild -scheme MacTool -configuration Debug -destination 'platform=macOS' build
```

Menu-bar only (`LSUIElement`) — tray uses SF Symbol `cursorarrow.click.2` with a countdown progress ring that fills over the selected Cursor Movement interval (e.g. 30 sec → full ring, then resets on nudge).

## Tray menu

1. **Cursor Movement** — Off | Every 30 sec | 1 min | 2 min | 5 min | 10 min (persisted)
2. **Settings…** — sidebar: **Cursor Movement** | **Permissions**
3. **Open at Login**
4. **Quit MacTool**

## Permissions (TCC)

| Permission | Required? | Why |
|---|---|---|
| **Accessibility** | Yes | Required to post synthetic `CGEvent` mouse events |
| **Input Monitoring** | Optional | MacTool does not monitor input |
| **Login Items** | Optional | Open at Login via `SMAppService` |

## Release (Developer ID DMG)

Credentials live in your shell env (not in the repo). See [`scripts/env.example`](scripts/env.example) and [`docs/release.md`](docs/release.md).

```bash
# after APPLE_TEAM_ID + APPLE_SIGN_IDENTITY in ~/.zshrc
./scripts/release.sh                 # notarized DMG + GitHub Release
./scripts/release.sh --skip-notarize # signed DMG + GitHub Release
```


> Prefer GitHub Releases / Developer ID over the Mac App Store: App Sandbox blocks synthetic input that affects other apps.

## Tests

```bash
xcodebuild -scheme MacTool -destination 'platform=macOS' test
```

## License

Copyright © 2026. All rights reserved.
