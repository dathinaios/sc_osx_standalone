#!/bin/bash
set -e

APP_NAME="${1:-SCStandalone}"
OUTPUT_DIR="${2:-./build}"

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
BUNDLED_FILES="$REPO/init.scd|$REPO/Frameworks|$REPO/Resources|$REPO/SCClassLibrary|$REPO/QT_PlugIns"

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
    "$REPO/run.sh" \
    "$OUTPUT_APP"

# Add microphone usage description so macOS prompts for audio access
/usr/libexec/PlistBuddy -c \
    "Add :NSMicrophoneUsageDescription string 'This app requires audio input.'" \
    "$OUTPUT_APP/Contents/Info.plist" 2>/dev/null || true

# Strip quarantine on the whole bundle (composer owns these files)
xattr -rd com.apple.quarantine "$OUTPUT_APP" 2>/dev/null || true

codesign --deep --force --sign - "$OUTPUT_APP"

echo "Built: $OUTPUT_APP"
