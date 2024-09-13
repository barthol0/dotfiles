#!/bin/bash

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

echo "Installing zsh-autosuggestions plugin..."
echo "Using ZSH_CUSTOM_DIR: $ZSH_CUSTOM_DIR"

if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
else
    echo "zsh-autosuggestions is already installed."
fi

echo "Updating ~/.zshrc to include zsh-autosuggestions..."
if ! grep -q "zsh-autosuggestions" "${HOME}/.zshrc"; then
    cp --dereference "${HOME}/.zshrc" "${HOME}/.zshrc.bak"
    sed -i '/^plugins=(/,/^)/ s/^)/  zsh-autosuggestions\n)/' "$(readlink -f "${HOME}/.zshrc")"
    echo "zsh-autosuggestions added to ~/.zshrc"
else
    echo "zsh-autosuggestions is already in ~/.zshrc."
fi
