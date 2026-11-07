# Releasing MacTool

Distributed via **Developer ID** + **DMG** on GitHub Releases (not the Mac App Store).

## Credentials (bashrc / zshrc)

List signing identities on this Mac:

```bash
security find-identity -v -p codesigning
```

Add exports (values from the command above — do **not** commit secrets):

```bash
# ~/.zshrc  (or ~/.bashrc)
export MACTOOL_TEAM_ID="YOUR_TEAM_ID"   # 10-char Team ID in parentheses
export MACTOOL_SIGN_IDENTITY="Developer ID Application: Your Name (YOUR_TEAM_ID)"
export MACTOOL_NOTARY_PROFILE="MacTool"
# export MACTOOL_APPLE_ID="you@example.com"   # only needed when storing notary creds
```

Template: [`scripts/env.example`](../scripts/env.example)

Reload:

```bash
source ~/.zshrc
```

### One-time notarization profile (Keychain)

```bash
xcrun notarytool store-credentials "$MACTOOL_NOTARY_PROFILE" \
  --apple-id "$MACTOOL_APPLE_ID" \
  --team-id "$MACTOOL_TEAM_ID" \
  --password "<app-specific-password>"   # https://appleid.apple.com → App-Specific Passwords
```

## Single release command

```bash
cd /path/to/MacTool
./scripts/release.sh                 # DMG + notarize + GitHub (needs notary profile)
./scripts/release.sh --skip-notarize # DMG signed only
```

Defaults: `MACTOOL_VERSION=1.0.1`, `MACTOOL_BUILD=1`.

Pipeline:

1. Archive Release with Developer ID + Hardened Runtime  
2. Build a **drop-to-Applications** DMG (`create-dmg` + background art)  
3. Sign the DMG  
4. Notarize + staple the DMG (unless `--skip-notarize`)  
5. Tag + GitHub Release uploading `MacTool-<version>.dmg`

### Flags

| Flag | Meaning |
|---|---|
| `--skip-notarize` | Skip Apple notary |
| `--skip-github` | Artifacts only |
| `--dry-run` | Print plan |

### Env vars

| Variable | Required | Notes |
|---|---|---|
| `MACTOOL_TEAM_ID` | yes | Apple Team ID |
| `MACTOOL_SIGN_IDENTITY` | yes | Full Developer ID Application identity string |
| `MACTOOL_NOTARY_PROFILE` | for notarize | Keychain profile name |
| `MACTOOL_VERSION` | no | default `1.0.1` |
| `MACTOOL_BUILD` | no | default `1` |

## Install from Releases

1. Download `MacTool-*.dmg`
2. Open → drag **MacTool** to **Applications**
3. Eject → launch from Applications

## Verify

```bash
codesign -dv --verbose=4 /Applications/MacTool.app
spctl --assess --type execute --verbose=4 /Applications/MacTool.app
```
