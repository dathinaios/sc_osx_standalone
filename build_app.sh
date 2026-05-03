#!/bin/bash
# Builds a SuperCollider standalone .app from this project.
#
# Usage:
#   ./build_app.sh                                                # defaults
#   ./build_app.sh MyPiece                                        # custom name
#   ./build_app.sh MyPiece path/to/init.scd                       # custom init
#   ./build_app.sh MyPiece init.scd ./out                         # custom output dir
#
# Forward extra flags to platypus_clt with --:
#   ./build_app.sh MyPiece init.scd ./build -- --interface-type None
#   ./build_app.sh MyPiece init.scd ./build -- --app-icon my.icns
#
# See `platypus_clt --help` or `man platypus` for available flags.

set -e

APP_NAME="${1:-SCStandalone}"
INIT_SCRIPT="${2:-init.scd}"
OUTPUT_DIR="${3:-./build}"

# Collect any extra args after `--` to forward to platypus_clt.
EXTRA_PLATYPUS_ARGS=()
while [ $# -gt 0 ]; do
    if [ "$1" = "--" ]; then
        shift
        EXTRA_PLATYPUS_ARGS=("$@")
        break
    fi
    shift
done

REPO="$(cd "$(dirname "$0")" && pwd -P)"
PLATYPUS_CLT="/Applications/Platypus.app/Contents/Resources/platypus_clt"

# Sanity checks
if [ ! -x "$PLATYPUS_CLT" ]; then
    echo "Platypus not found at $PLATYPUS_CLT"
    echo "Install Platypus from https://sveinbjorn.org/platypus"
    exit 1
fi
if [ ! -d "$REPO/Frameworks" ]; then
    echo "Frameworks folder missing. Unzip Frameworks.zip first:"
    echo "    cd $REPO && unzip Frameworks.zip"
    exit 1
fi
if [ ! -f "$INIT_SCRIPT" ]; then
    echo "init script not found: $INIT_SCRIPT"
    exit 1
fi

INIT_SCRIPT_ABS="$(cd "$(dirname "$INIT_SCRIPT")" && pwd -P)/$(basename "$INIT_SCRIPT")"

# Stage everything into a temp dir so we can swap in a custom init.scd
# without touching the repo.
TMP_STAGE="$(mktemp -d)/sc_standalone"
mkdir -p "$TMP_STAGE"
cp -R "$REPO/run.sh" "$TMP_STAGE/"
cp -R "$REPO/Frameworks" "$TMP_STAGE/"
cp -R "$REPO/Resources" "$TMP_STAGE/"
cp -R "$REPO/SCClassLibrary" "$TMP_STAGE/"
cp -R "$REPO/QT_PlugIns" "$TMP_STAGE/"
cp "$INIT_SCRIPT_ABS" "$TMP_STAGE/init.scd"

BUNDLED_FILES="$TMP_STAGE/init.scd|$TMP_STAGE/Frameworks|$TMP_STAGE/Resources|$TMP_STAGE/SCClassLibrary|$TMP_STAGE/QT_PlugIns"

mkdir -p "$OUTPUT_DIR"
OUTPUT_APP="$OUTPUT_DIR/$APP_NAME.app"

BUNDLE_ID="org.supercollider.standalone.$(echo "$APP_NAME" | tr -d ' ' | tr '[:upper:]' '[:lower:]')"

"$PLATYPUS_CLT" \
    --name "$APP_NAME" \
    --interface-type 'Text Window' \
    --bundle-identifier "$BUNDLE_ID" \
    --interpreter '/bin/bash' \
    --bundled-file "$BUNDLED_FILES" \
    --overwrite \
    "${EXTRA_PLATYPUS_ARGS[@]}" \
    "$TMP_STAGE/run.sh" \
    "$OUTPUT_APP"

# Strip quarantine on the whole bundle (composer owns these files)
xattr -rd com.apple.quarantine "$OUTPUT_APP" 2>/dev/null || true

codesign --deep --force --sign - "$OUTPUT_APP"

# Clean up staging dir
rm -rf "$TMP_STAGE"

echo
echo "Built: $OUTPUT_APP"
echo
echo "Performer instructions:"
echo "  1. Right-click the .app, choose Open, click Open in the Gatekeeper dialog."
echo "  2. Allow microphone access if prompted."
echo "  3. Future launches just work."
