# Releasing MacTool

MacTool is distributed **outside the Mac App Store** via **Developer ID** signing (and notarization when credentials are configured). Synthetic cursor events require a non-sandboxed build.

## Prerequisites

- Xcode + command-line tools
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- Developer ID Application certificate in the login keychain  
  (this machine: `Developer ID Application: Abhishek Bhalerao (44GWMTNP57)`)
- Team ID: `44GWMTNP57`
- Bundle ID: `in.abappdev.MacTool`
- `gh` authenticated to [abappdev/MacTool](https://github.com/abappdev/MacTool)

### One-time notarization (recommended)

1. Create an [app-specific password](https://appleid.apple.com) for your Apple ID.
2. Store a notarytool profile:

```bash
xcrun notarytool store-credentials "MacTool" \
  --apple-id "YOUR_APPLE_ID" \
  --team-id "44GWMTNP57" \
  --password "app-specific-password"
```

## Single release command

```bash
cd /Users/ab/DeveloperStudio/MacTool
./scripts/release.sh
```

This will:

1. Set version **1.0.0** (override with `MACTOOL_VERSION` / `MACTOOL_BUILD`)
2. Regenerate the Xcode project from `project.yml`
3. Archive a **Release** build
4. Sign with **Developer ID** + Hardened Runtime + secure timestamp
5. Zip `dist/MacTool-<version>.zip` (+ `.sha256`)
6. Notarize + staple (unless `--skip-notarize`)
7. Commit if needed, tag `v<version>`, push, and create a **GitHub Release** with the zip

### Useful flags

| Flag | Meaning |
|---|---|
| `--skip-notarize` | Signed zip only (Gatekeeper may warn until notarized) |
| `--skip-github` | Build artifacts only; no tag/release |
| `--dry-run` | Print the plan |

### Environment overrides

| Variable | Default |
|---|---|
| `MACTOOL_VERSION` | `1.0.0` |
| `MACTOOL_BUILD` | `1` |
| `MACTOOL_TEAM_ID` | `44GWMTNP57` |
| `MACTOOL_SIGN_IDENTITY` | `Developer ID Application: Abhishek Bhalerao (44GWMTNP57)` |
| `MACTOOL_NOTARY_PROFILE` | `MacTool` |

## Install from GitHub Releases

1. Download `MacTool-1.0.0.zip` from [Releases](https://github.com/abappdev/MacTool/releases)
2. Unzip → move `MacTool.app` to `/Applications`
3. First open: right-click → **Open** if macOS shows a warning
4. Enable **Accessibility** for MacTool when using Cursor Movement

## Verify a local build

```bash
codesign -dv --verbose=4 /Applications/MacTool.app
spctl --assess --type execute --verbose=4 /Applications/MacTool.app
```
