#!/usr/bin/env bash
# MacTool release: archive → Developer ID sign → drop-to-Applications DMG →
# (optional) notarize + staple → GitHub Release.
#
# Shared signing env (put in ~/.zshrc — common across apps):
#   APPLE_TEAM_ID
#   APPLE_SIGN_IDENTITY
# Notary profile is hardcoded to "MacTool" (Keychain via notarytool store-credentials).
# Optional:
#   MACTOOL_VERSION (default 1.0.1)
#   MACTOOL_BUILD (default 1)
#
# Usage:
#   ./scripts/release.sh
#   ./scripts/release.sh --skip-notarize
#   ./scripts/release.sh --skip-github
#   ./scripts/release.sh --dry-run
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${MACTOOL_VERSION:-1.0.1}"
BUILD_NUMBER="${MACTOOL_BUILD:-1}"
TEAM_ID="${APPLE_TEAM_ID:-}"
SIGN_IDENTITY="${APPLE_SIGN_IDENTITY:-}"
BUNDLE_ID="in.abappdev.MacTool"
SCHEME="MacTool"
CONFIGURATION="Release"
# Hardcoded Keychain profile name for this app (notarytool store-credentials "MacTool").
NOTARY_PROFILE="MacTool"
DERIVED="${ROOT}/build/DerivedData"
ARCHIVE_PATH="${ROOT}/build/MacTool.xcarchive"
EXPORT_DIR="${ROOT}/build/export"
DMG_STAGE="${ROOT}/build/dmg-stage"
DIST_DIR="${ROOT}/dist"
APP_NAME="MacTool.app"
DMG_NAME="MacTool-${VERSION}.dmg"
BACKGROUND_PNG="${ROOT}/scripts/dmg-background.png"

SKIP_NOTARIZE=0
SKIP_GITHUB=0
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --skip-notarize) SKIP_NOTARIZE=1 ;;
    --skip-github) SKIP_GITHUB=1 ;;
    --dry-run) DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,24p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 2
      ;;
  esac
done

log() { printf '==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

require_cmd xcodebuild
require_cmd codesign
require_cmd ditto
require_cmd xcrun
require_cmd git
require_cmd create-dmg
require_cmd hdiutil

if [[ "$SKIP_GITHUB" -eq 0 ]]; then
  require_cmd gh
fi

[[ -n "$TEAM_ID" ]] || die "APPLE_TEAM_ID is not set (add to ~/.zshrc — see scripts/env.example)"
[[ -n "$SIGN_IDENTITY" ]] || die "APPLE_SIGN_IDENTITY is not set (add to ~/.zshrc — see scripts/env.example)"

if ! security find-identity -v -p codesigning | grep -F "$SIGN_IDENTITY" >/dev/null; then
  die "codesigning identity not found. Run: security find-identity -v -p codesigning"
fi

if [[ "$SKIP_NOTARIZE" -eq 0 ]]; then
  if ! xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null 2>&1; then
    cat >&2 <<EOF
error: notarytool keychain profile "$NOTARY_PROFILE" not found.

Store once (app-specific password — not in git):
  xcrun notarytool store-credentials "$NOTARY_PROFILE" \\
    --apple-id "\$MACTOOL_APPLE_ID" --team-id "$TEAM_ID" --password "app-specific-password"

Or re-run with --skip-notarize.
EOF
    exit 1
  fi
fi

if [[ "$DRY_RUN" -eq 1 ]]; then
  cat <<EOF
Dry run plan:
  version=$VERSION build=$BUILD_NUMBER
  team=$TEAM_ID
  identity=$SIGN_IDENTITY
  notarize=$([[ $SKIP_NOTARIZE -eq 0 ]] && echo yes || echo no) profile=$NOTARY_PROFILE
  github=$([[ $SKIP_GITHUB -eq 0 ]] && echo yes || echo no)
  dmg=$DIST_DIR/$DMG_NAME
EOF
  exit 0
fi

log "Set marketing version $VERSION (build $BUILD_NUMBER)"
if [[ -f project.yml ]]; then
  require_cmd xcodegen
  perl -pi -e "s/CURRENT_PROJECT_VERSION:\\s*.*/CURRENT_PROJECT_VERSION: ${BUILD_NUMBER}/" project.yml
  perl -pi -e "s/MARKETING_VERSION:\\s*\".*\"/MARKETING_VERSION: \"${VERSION}\"/" project.yml
  # Keep team id in sync for Xcode Automatic signing without embedding a personal name.
  perl -pi -e "s/DEVELOPMENT_TEAM:\\s*\".*\"/DEVELOPMENT_TEAM: \"${TEAM_ID}\"/" project.yml
  xcodegen generate
  /usr/libexec/PlistBuddy -c 'Set :CFBundleShortVersionString $(MARKETING_VERSION)' MacTool/Resources/Info.plist 2>/dev/null \
    || /usr/libexec/PlistBuddy -c 'Add :CFBundleShortVersionString string $(MARKETING_VERSION)' MacTool/Resources/Info.plist
  /usr/libexec/PlistBuddy -c 'Set :CFBundleVersion $(CURRENT_PROJECT_VERSION)' MacTool/Resources/Info.plist 2>/dev/null \
    || /usr/libexec/PlistBuddy -c 'Add :CFBundleVersion string $(CURRENT_PROJECT_VERSION)' MacTool/Resources/Info.plist
fi

log "Clean build directories"
rm -rf "$DERIVED" "$ARCHIVE_PATH" "$EXPORT_DIR" "$DMG_STAGE"
mkdir -p "$DIST_DIR" "$EXPORT_DIR" "$DERIVED" "$DMG_STAGE"

log "Archive Release"
xcodebuild \
  -project MacTool.xcodeproj \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "generic/platform=macOS" \
  -derivedDataPath "$DERIVED" \
  -archivePath "$ARCHIVE_PATH" \
  MARKETING_VERSION="$VERSION" \
  CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$SIGN_IDENTITY" \
  OTHER_CODE_SIGN_FLAGS="--timestamp" \
  ENABLE_HARDENED_RUNTIME=YES \
  archive

APP_IN_ARCHIVE="$ARCHIVE_PATH/Products/Applications/$APP_NAME"
[[ -d "$APP_IN_ARCHIVE" ]] || die "archive did not produce $APP_NAME"

log "Export + sign app"
rm -rf "$EXPORT_DIR/$APP_NAME"
ditto "$APP_IN_ARCHIVE" "$EXPORT_DIR/$APP_NAME"
codesign --force --deep --options runtime --timestamp \
  --sign "$SIGN_IDENTITY" \
  --entitlements MacTool/Resources/MacTool.entitlements \
  "$EXPORT_DIR/$APP_NAME"
codesign --verify --deep --strict --verbose=2 "$EXPORT_DIR/$APP_NAME"

if [[ ! -f "$BACKGROUND_PNG" ]]; then
  log "Generate DMG background"
  if [[ -x "$ROOT/.tools-venv/bin/python" ]]; then
    "$ROOT/.tools-venv/bin/python" "$ROOT/scripts/generate_dmg_background.py"
  else
    python3 "$ROOT/scripts/generate_dmg_background.py"
  fi
fi

log "Stage DMG contents (app + Applications shortcut)"
ditto "$EXPORT_DIR/$APP_NAME" "$DMG_STAGE/$APP_NAME"
ln -s /Applications "$DMG_STAGE/Applications"

log "Create drop-to-Applications DMG"
rm -f "$DIST_DIR/$DMG_NAME"
CREATE_DMG_ARGS=(
  --volname "MacTool ${VERSION}"
  --background "$BACKGROUND_PNG"
  --window-pos 200 120
  --window-size 660 400
  --icon-size 128
  --icon "$APP_NAME" 160 190
  --hide-extension "$APP_NAME"
  --app-drop-link 480 190
  --no-internet-enable
)
ICNS="$EXPORT_DIR/$APP_NAME/Contents/Resources/AppIcon.icns"
if [[ -f "$ICNS" ]]; then
  CREATE_DMG_ARGS+=(--volicon "$ICNS")
fi
# create-dmg may exit non-zero after AppleScript layout quirks; accept if DMG exists.
create-dmg "${CREATE_DMG_ARGS[@]}" "$DIST_DIR/$DMG_NAME" "$DMG_STAGE" || true
[[ -f "$DIST_DIR/$DMG_NAME" ]] || die "DMG was not created"

log "Sign DMG"
codesign --force --sign "$SIGN_IDENTITY" --timestamp "$DIST_DIR/$DMG_NAME"
codesign --verify --verbose=2 "$DIST_DIR/$DMG_NAME"

if [[ "$SKIP_NOTARIZE" -eq 0 ]]; then
  log "Notarize DMG (profile=$NOTARY_PROFILE)"
  xcrun notarytool submit "$DIST_DIR/$DMG_NAME" \
    --keychain-profile "$NOTARY_PROFILE" \
    --wait
  log "Staple notarization ticket to DMG"
  xcrun stapler staple "$DIST_DIR/$DMG_NAME"
  xcrun stapler validate "$DIST_DIR/$DMG_NAME"
fi

shasum -a 256 "$DIST_DIR/$DMG_NAME" | tee "$DIST_DIR/$DMG_NAME.sha256"

BUILT_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$EXPORT_DIR/$APP_NAME/Contents/Info.plist")"
BUILT_BUILD="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$EXPORT_DIR/$APP_NAME/Contents/Info.plist")"
log "Built $BUNDLE_ID version=$BUILT_VERSION build=$BUILT_BUILD"

if [[ "$SKIP_GITHUB" -eq 0 ]]; then
  TAG="v${VERSION}"
  log "Commit + push"
  git add -A
  if ! git diff --cached --quiet; then
    git commit -m "Release ${VERSION}

Ship MacTool ${VERSION} (build ${BUILD_NUMBER}) as a Developer ID–signed
drop-to-Applications DMG via scripts/release.sh."
  fi
  git push -u origin HEAD

  if git rev-parse "$TAG" >/dev/null 2>&1; then
    log "Tag $TAG already exists"
  else
    git tag -a "$TAG" -m "MacTool ${VERSION}"
  fi
  git push origin "$TAG" || true

  NOTES_FILE="$(mktemp)"
  NOTARY_LINE="Developer ID–signed"
  if [[ "$SKIP_NOTARIZE" -eq 0 ]]; then
    NOTARY_LINE="Developer ID–signed and notarized"
  fi
  cat >"$NOTES_FILE" <<EOF
## MacTool ${VERSION}

${NOTARY_LINE} macOS menu-bar build (\`${BUNDLE_ID}\`).

### Install
1. Download \`MacTool-${VERSION}.dmg\`
2. Open the disk image
3. Drag **MacTool** onto **Applications**
4. Eject the disk image
5. Open MacTool from Applications (right-click → **Open** if macOS warns)
6. Grant **Accessibility** when enabling Cursor Movement (Settings → Permissions)

### Verify
\`\`\`bash
codesign -dv --verbose=4 /Applications/MacTool.app
spctl --assess --type execute /Applications/MacTool.app
\`\`\`

Team ID: \`${TEAM_ID}\` · Build: \`${BUILT_BUILD}\`
EOF

  if gh release view "$TAG" >/dev/null 2>&1; then
    log "Updating GitHub release $TAG"
    gh release upload "$TAG" "$DIST_DIR/$DMG_NAME" "$DIST_DIR/$DMG_NAME.sha256" --clobber
  else
    log "Creating GitHub release $TAG"
    gh release create "$TAG" \
      "$DIST_DIR/$DMG_NAME" \
      "$DIST_DIR/$DMG_NAME.sha256" \
      --title "MacTool ${VERSION}" \
      --notes-file "$NOTES_FILE"
  fi
  rm -f "$NOTES_FILE"
  log "Release URL: $(gh release view "$TAG" --json url -q .url)"
fi

log "Done → $DIST_DIR/$DMG_NAME"
