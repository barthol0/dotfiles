#!/bin/bash

# Check if required software is installed
if ! command -v git &>/dev/null; then
    echo "git could not be found, please install it first."
    exit
fi

if ! command -v stow &>/dev/null; then
    echo "stow could not be found, please install it first."
fi

if ! command -v make &>/dev/null; then
    echo "make could not be found, please install it first."
fi

# Clone the dotfiles repository if it doesn't exist
DOTFILES_DIR=~/dotfiles
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone https://github.com/barthol0/dotfiles.git $DOTFILES_DIR
fi

cd $DOTFILES_DIR

echo "-##########-THIS IS TEST-##########-"
# stow tmux
# stow ranger
# stow zsh
# stow vim
# stow git
