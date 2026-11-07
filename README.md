# MacTool

macOS **menu-bar** utility. First feature: **Cursor Movement** — schedules tiny (1px) synthetic cursor movements via Accessibility APIs.

**Download:** [GitHub Releases](https://github.com/abappdev/MacTool/releases) · **Current:** v1.0.0  
**Bundle ID:** `in.abappdev.MacTool`

## Install (release build)

1. Grab `MacTool-1.0.0.zip` from [Releases](https://github.com/abappdev/MacTool/releases/latest)
2. Unzip and move `MacTool.app` to **Applications**
3. Open once (right-click → **Open** if Gatekeeper warns)
4. When you enable Cursor Movement, grant **Accessibility** (Settings → Permissions)

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
open /Users/ab/DeveloperStudio/MacTool/MacTool.xcodeproj
```

Or:

```bash
cd /Users/ab/DeveloperStudio/MacTool
xcodebuild -scheme MacTool -configuration Debug -destination 'platform=macOS' build
```

Menu-bar only (`LSUIElement`) — tray uses SF Symbol `cursorarrow.click.2`. App Icon lives in `MacTool/Resources/Assets.xcassets/AppIcon.appiconset/`.

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

## Release (Developer ID)

One script builds, signs, zips, optionally notarizes, and publishes to GitHub:

```bash
./scripts/release.sh                 # notarize + GitHub Release (needs notarytool profile)
./scripts/release.sh --skip-notarize # Developer ID signed zip + GitHub Release
```

Full notes: [docs/release.md](docs/release.md). Architecture: [docs/architecture.md](docs/architecture.md).

> Mac App Store distribution is not recommended for this feature: App Sandbox blocks synthetic input that affects other apps. Prefer Developer ID / GitHub Releases.

## Tests

```bash
cd /Users/ab/DeveloperStudio/MacTool
xcodebuild -scheme MacTool -destination 'platform=macOS' test
```

## License

Copyright © 2026 Abhishek Bhalerao. All rights reserved.
