#!/usr/bin/env bash
#
# Package MythicPlusBox for distribution.
#
# Reads the version from the addon's TOC and produces MPBox-v<version>.zip
# containing a single top-level `MythicPlusBox/` folder so it extracts straight
# into Interface/AddOns/. The reference folders zMPlus/, Stats/, Details/ live
# alongside the addon at the repo root and are excluded automatically because
# rsync is pointed at the addon subdirectory only.
#
# Usage: bash release.sh
set -euo pipefail

ADDON="MythicPlusBox"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/$ADDON"
cd "$ROOT"

if [ ! -d "$SRC" ]; then
    echo "error: expected addon directory at $SRC" >&2
    exit 1
fi

VERSION="$(grep -E '^## Version:' "$SRC/$ADDON.toc" | head -1 | sed -E 's/^## Version:[[:space:]]*//')"
if [ -z "$VERSION" ]; then
    echo "error: could not read '## Version' from $SRC/$ADDON.toc" >&2
    exit 1
fi

ZIP="MPBox-v$VERSION.zip"
STAGE="$(mktemp -d)"
DEST="$STAGE/$ADDON"
mkdir -p "$DEST"

rsync -a \
    --exclude '.git' \
    --exclude '.github' \
    --exclude '.gitignore' \
    --exclude '.claude' \
    --exclude 'CLAUDE.md' \
    --exclude 'release.sh' \
    --exclude '*.zip' \
    --exclude '.DS_Store' \
    --exclude 'Media/*.png' \
    "$SRC/" "$DEST/"

rm -f "$ROOT/$ZIP"
( cd "$STAGE" && zip -r -q "$ROOT/$ZIP" "$ADDON" )
rm -rf "$STAGE"

echo "Created $ZIP (version $VERSION)"
