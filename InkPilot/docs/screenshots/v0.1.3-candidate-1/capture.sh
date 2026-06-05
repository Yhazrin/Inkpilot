#!/bin/bash
# V0.1.3 candidate-1 screenshot capture script.
# Usage: ./capture.sh
set -e

OUT=docs/screenshots/v0.1.3-candidate-1
mkdir -p "$OUT"
BUNDLE=com.inkpilot.app

shoot() {
    local name=$1
    shift
    local args="$@"
    xcrun simctl terminate booted $BUNDLE 2>/dev/null || true
    sleep 0.3
    xcrun simctl launch booted $BUNDLE -autoCanvas 1 -nukePersist 1 $args > /dev/null
    sleep 1.5
    xcrun simctl io booted screenshot "$OUT/$name.png" 2>&1 | tail -1
    echo "  → $OUT/$name.png"
}

echo "[2/9] select tool"
shoot 02-tool-select "-tool select"

echo "[2b] pen tool (collapsed indicator — should be small, not full palette)"
shoot 02b-tool-pen-collapsed "-tool pen"

echo "[3/9] select with lasso mode"
shoot 03-tool-select-lasso "-tool select -useLasso 1"

echo "[4/9] text tool"
shoot 04-tool-text "-tool text"

echo "[5/9] shape palette open"
shoot 05-palette-shape "-palette shape"

echo "[6/9] media palette open"
shoot 06-palette-media "-palette media"

echo "[7/9] seeded objects (text + sticky + shape)"
shoot 07-seeded-objects "-tool select -seedObjects 1"

echo "[8/9] ghost suggestion visible"
shoot 08-ghost-suggestion "-tool select -triggerGhost 1"

echo "[9/9] export sheet (with objects to ensure non-empty image)"
shoot 09-export-sheet "-tool select -seedObjects 1 -showExportSheet 1"

echo ""
echo "Done. $OUT/ has 9 screenshots."
