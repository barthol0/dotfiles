#!/bin/bash

# Function to check if mpv is installed
check_mpv_installation() {
    if ! command -v mpv &>/dev/null; then
        echo "mpv is not installed. Please install mpv and rerun the script."
        exit 1
    else
        echo "mpv is installed, proceeding with the setup..."
    fi
}

# Function to install UOSC
install_uosc() {
    echo "Installing UOSC..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh)"
}

# Function to install Thumbfast for thumbnail preview
install_thumbfast() {
    echo "Installing Thumbfast for thumbnail preview..."
    mkdir -p ~/.config/mpv/scripts/
    curl -L https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.lua -o ~/.config/mpv/scripts/thumbfast.lua
    mkdir -p ~/.config/mpv/script-opts/
    curl -L https://raw.githubusercontent.com/po5/thumbfast/master/thumbfast.conf -o ~/.config/mpv/script-opts/thumbfast.conf
}

# Function to configure mpv.conf
configure_mpv_conf() {
    echo "Configuring mpv.conf..."
    cat <<EOT >~/.config/mpv/mpv.conf
# keep open at end
keep-open=yes

# always spawn the window in 960x487 and in the center of the screen
geometry=960x487

# add black bars to either sides to keep the aspect ratio specified by geometry
no-keepaspect-window

# set file loop
loop-file=inf

EOT
}

# Function to install persist-properties script and set configuration
install_persist_properties() {
    echo "Installing persist-properties script..."
    mkdir -p ~/.config/mpv/scripts/
    curl -L https://raw.githubusercontent.com/d87/mpv-persist-properties/master/persist-properties.lua -o ~/.config/mpv/scripts/persist-properties.lua

    echo "Setting persist_properties configuration..."
    echo "properties=volume,sub-scale" >~/.config/mpv/script-opts/persist_properties.conf
}

# Function to set custom keyboard shortcuts in input.conf
configure_input_conf() {
    echo "Configuring custom keyboard shortcuts in input.conf..."
    cat <<'EOT' >~/.config/mpv/input.conf

Alt+k playlist-shuffle ; show-text "playlist shuffled" 2000 
p playlist-prev
n playlist-next

Shift+Del run gio trash ${path}; playlist-remove current

tab  script-binding uosc/toggle-ui

EOT
}

check_mpv_installation
install_uosc
install_thumbfast
configure_mpv_conf
install_persist_properties
configure_input_conf

echo "MPV setup complete with UOSC and Thumbfast!"
