#!/bin/bash
# Used by RStudio's Build button (see crime_mapping_workshop.Rproj).
# Renders the whole site, then serves it locally and opens it in your browser.
# Press the red Stop button in the Build pane to stop the preview server.
cd "$(dirname "$0")"

QUARTO="$(command -v quarto)"
# Fall back to the copy of Quarto bundled with RStudio
for p in "/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto" \
         "/Applications/RStudio.app/Contents/MacOS/quarto/bin/quarto" \
         "/usr/local/bin/quarto" "/opt/homebrew/bin/quarto"; do
  [ -z "$QUARTO" ] && [ -x "$p" ] && QUARTO="$p"
done

if [ -z "$QUARTO" ]; then
  echo "Quarto not found. Install it from https://quarto.org/docs/get-started/ and try again."
  exit 1
fi

echo "Using Quarto: $QUARTO ($("$QUARTO" --version))"
"$QUARTO" preview --render all
