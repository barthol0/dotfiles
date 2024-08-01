# Define variables
DOTFILES_DIR=$(HOME)/dotfiles
TARGET_DIR=$(HOME)
TPM_DIR=$(TARGET_DIR)/.tmux/plugins/tpm


all: setup-tmux

setup-tmux: install-tpm stow-tmux install-plugins

stow-tmux:
	@echo "Stowing tmux configuration..."
	stow -v -d $(DOTFILES_DIR) -t $(TARGET_DIR) tmux

stow-zsh:
	@echo "Stowing zsh configuration..."
	stow -v -d $(DOTFILES_DIR) -t $(TARGET_DIR) zsh

stow-ranger:
	@echo "Stowing ranger configuration..."
	stow -v -d $(DOTFILES_DIR) -t $(TARGET_DIR) ranger

tmux-install-tpm:
	@echo "Installing TPM (Tmux Plugin Manager)..."
	@if [ ! -d $(TPM_DIR) ]; then \
		git clone https://github.com/tmux-plugins/tpm $(TPM_DIR); \
	fi

tmux-install-plugins:
	@echo "Installing tmux plugins..."
	$(TARGET_DIR)/.tmux/plugins/tpm/bin/install_plugins

# Clean target to remove all stowed configurations
clean:
	@echo "Cleaning up stowed configurations..."
	stow -D -v -d $(DOTFILES_DIR) -t $(TARGET_DIR) tmux zsh

.PHONY: all stow-tmux stow-zsh install-tpm install-plugins clean