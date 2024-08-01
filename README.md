```
      ██            ██     ████ ██  ██
     ░██           ░██    ░██░ ░░  ░██
     ░██  ██████  ██████ ██████ ██ ░██  █████   ██████
  ██████ ██░░░░██░░░██░ ░░░██░ ░██ ░██ ██░░░██ ██░░░░
 ██░░░██░██   ░██  ░██    ░██  ░██ ░██░███████░░█████
░██  ░██░██   ░██  ░██    ░██  ░██ ░██░██░░░░  ░░░░░██
░░██████░░██████   ░░██   ░██  ░██ ███░░██████ ██████
 ░░░░░░  ░░░░░░     ░░    ░░   ░░ ░░░  ░░░░░░ ░░░░░░
```

# dotfiles

## Requirements

-   git
-   stow
-   make
-   curl / wget

## Install

Using `curl`:

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/barthol0/dotfiles/master/remote-install.sh)"
```

Using `wget`:

```
bash -c "$(wget -qO- https://raw.githubusercontent.com/barthol0/dotfiles/master/remote-install.sh)"
```

## Configure manually

```
cd ~/dotfiles
```

### tmux:

```
make setup-tmux
```
