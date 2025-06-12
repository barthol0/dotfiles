#!/bin/bash

FONT_NAME="$1"

if [ -z "$FONT_NAME" ]; then
    echo "Usage: $0 <FontName>"
    echo "Example: $0 FiraCode"
    exit 1
fi

NERD_FONTS_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"
DEST_DIR="$HOME/.local/share/fonts"

mkdir -p "$DEST_DIR"
cd /tmp || exit
echo "Downloading ${FONT_NAME} Nerd Font..."
curl -fLo "${FONT_NAME}.zip" "$NERD_FONTS_URL" || {
    echo "❌ Failed to download ${FONT_NAME}. Are you sure the font name is correct?"
    exit 1
}
unzip -o "${FONT_NAME}.zip" -d "$DEST_DIR"
fc-cache -fv

echo "✅ Installed ${FONT_NAME} Nerd Font to $DEST_DIR"
