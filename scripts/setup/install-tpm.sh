#!/bin/bash

TARGET_DIR="${HOME}"
TPM_DIR="${TARGET_DIR}/.tmux/plugins/tpm"

echo "Installing TPM (Tmux Plugin Manager)..."
if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "TPM is already installed."
fi

echo "Installing tmux plugins..."
"${TPM_DIR}/bin/install_plugins"
