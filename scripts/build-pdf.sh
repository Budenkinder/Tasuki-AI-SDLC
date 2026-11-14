#!/usr/bin/env bash
# Builds Tasuki-AI-SDLC.pdf from README.md (pandoc -> HTML -> headless Chrome).
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="${1:-Tasuki-AI-SDLC.pdf}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# The PDF does not need the "Create a PDF" section or the link to itself.
# The cover page (scripts/cover.html) replaces the README title block.
sed -e '/^## Create a PDF/,/^## License/{/^## License/!d}' \
    -e '/^- \[Create a PDF\]/d' \
    -e '1,/^Author: /d' README.md > "$TMP/doc.md"

DATE="$(sed -n 's/^Author: .*Last updated: \([0-9-]*\).*/\1/p' README.md)"
sed "s/__DATE__/${DATE:-$(date +%F)}/" scripts/cover.html > "$TMP/cover.html"

pandoc "$TMP/doc.md" -f gfm -t html5 --standalone \
  --lua-filter scripts/alerts.lua --include-before-body "$TMP/cover.html" \
  --metadata title="Tasuki – AI SDLC" --metadata pagetitle="Tasuki – AI SDLC" \
  --variable title="" \
  --css "$PWD/scripts/pdf.css" --embed-resources --resource-path=. \
  -o "$TMP/doc.html"

CHROME="$(command -v google-chrome || command -v chromium || command -v chromium-browser || true)"
if [ -z "$CHROME" ]; then echo "Google Chrome or Chromium is required" >&2; exit 1; fi

"$CHROME" --headless=new --disable-gpu --no-sandbox --no-pdf-header-footer \
  --print-to-pdf="$PWD/$OUT" "file://$TMP/doc.html" 2>/dev/null
echo "Wrote $OUT"
