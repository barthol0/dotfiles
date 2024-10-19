DOTFILES_DIR=$(HOME)/dotfiles
TARGET_DIR=$(HOME)

all: setup-tmux setup-zsh stow-alacritty

setup-tmux: stow-tmux tmux-install-tpm

setup-zsh: stow-zsh install-zsh-autosuggestions

stow-alacritty:
	@echo "Stowing alacritty configuration..."
	stow -v -d $(DOTFILES_DIR) -t $(TARGET_DIR)/.config/alacritty alacritty
	@echo "...Done."

stow-tmux:
	@echo "Stowing tmux configuration..."
	stow -v -d $(DOTFILES_DIR) -t $(TARGET_DIR) tmux
	@echo "...Done."

stow-zsh:
	@echo "Stowing zsh configuration..."
	stow -v -d $(DOTFILES_DIR) -t $(TARGET_DIR) zsh
	@echo "...Done."

stow-ranger:
	@echo "Stowing ranger configuration..."
	stow -v -d $(DOTFILES_DIR) -t $(TARGET_DIR) ranger
	@echo "...Done."

tmux-install-tpm:
	@echo "Running TPM installation script..."
	@./scripts/setup/install-tpm.sh
	@echo "...Done."

install-zsh-autosuggestions:
	@echo "Running zsh-autosuggestions installation script..."
	@./scripts/setup/install-zsh-autosuggestions.sh
	@echo "...Done."

mpv-config:
	@echo "Running mpv configuration script..."
	@./scripts/setup/mpv-config-with-uosc-thumbfast.sh
	@echo "...Done."

clean:
	@echo "Cleaning up stowed configurations..."
	stow -D -v -d $(DOTFILES_DIR) -t $(TARGET_DIR) tmux zsh

.PHONY: all stow-tmux stow-zsh stow-alacritty install-tpm install-plugins mpv-config clean