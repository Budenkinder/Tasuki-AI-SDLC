#!/usr/bin/env bash
# Builds Tasuki-AI-SDLC.pdf from README.md (pandoc -> HTML -> headless Chrome).
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${1:-Tasuki-AI-SDLC.pdf}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# The PDF does not need the "Create a PDF" section or the link to itself.
sed -e '/^## Create a PDF/,$d' \
    -e '/^- \[Create a PDF\]/d' \
    -e 's/ · Current version: \[PDF\]([^)]*)//' README.md > "$TMP/doc.md"

pandoc "$TMP/doc.md" -f gfm -t html5 --standalone \
  --lua-filter scripts/alerts.lua \
  --metadata title="Tasuki – AI SDLC" --metadata pagetitle="Tasuki – AI SDLC" \
  --variable title="" \
  --css "$PWD/scripts/pdf.css" --embed-resources --resource-path=. \
  -o "$TMP/doc.html"

CHROME="$(command -v google-chrome || command -v chromium || command -v chromium-browser || true)"
if [ -z "$CHROME" ]; then echo "Google Chrome or Chromium is required" >&2; exit 1; fi

"$CHROME" --headless=new --disable-gpu --no-sandbox --no-pdf-header-footer \
  --print-to-pdf="$PWD/$OUT" "file://$TMP/doc.html" 2>/dev/null
echo "Wrote $OUT"
