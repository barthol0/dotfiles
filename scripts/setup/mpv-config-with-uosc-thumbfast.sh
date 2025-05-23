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
idle=yes

# always spawn the window in 960x487 and in the center of the screen
geometry=960x487

# add black bars to either sides to keep the aspect ratio specified by geometry
no-keepaspect-window

# disable auto resize
auto-window-resize=no

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

Alt+k playlist-shuffle ; show-text "playlist shuffled" 3000
p playlist-prev
n playlist-next

WHEEL_UP seek 10
WHEEL_DOWN seek -10

Shift+Del run gio trash ${path}; show-text "DELETED:\n${filename}" 5000; playlist-remove current

tab  script-binding uosc/toggle-ui

k show-text "Loop A: ${ab-loop-a}\nLoop B: ${ab-loop-b}"
EOT
}

install_save_loop_to_json() {
    echo "Installing save-loop-to-json script..."
    cat <<EOT > ~/.config/mpv/scripts/save-loop-to-json.lua
local utils = require 'mp.utils'

-- Simple hash function for the filename
local function simple_hash(str)
    local hash = 0
    for i = 1, #str do
        hash = (hash * 31 + str:byte(i)) % 2 ^ 32
    end
    return string.format("%x", hash) -- Convert to hexadecimal
end

function save_loop_to_json()
    -- Get the A-B loop points (in seconds)
    local loop_a = mp.get_property_number("ab-loop-a")
    local loop_b = mp.get_property_number("ab-loop-b")
    local filepath = mp.get_property("path")

    -- Check if loop points and filepath are valid
    if loop_a == nil or loop_b == nil or filepath == nil then
        mp.osd_message("Error: Loop points or file path not set", 2)
        return
    end

    -- Get the current date and time in YYYYMMDDHHMMSS format (e.g., 20250306154120)
    local timestamp = os.date("%Y%m%d%H%M%S")

    -- Generate a hash from the filename
    local filename_hash = simple_hash(filepath)

    -- Define the output directory and ensure it exists
    local output_dir = os.getenv("HOME") .. "/mpv_loops"
    os.execute("mkdir -p " .. output_dir) -- Create directory if it doesn't exist

    -- Define the output filename (hash-timestamp.json)
    local output_file = output_dir .. "/" .. filename_hash .. "-" .. timestamp .. ".json"

    -- Prepare the data structure
    local data = {
        file = filepath,
        loop_start = loop_a,
        loop_end = loop_b
    }

    -- Convert to JSON string
    local json_data = utils.format_json(data)

    -- Write to the file (overwrite mode for individual files)
    local file = io.open(output_file, "w")
    if file then
        file:write(json_data)
        file:close()
        mp.osd_message("Saved loop to " .. output_file, 2)
    else
        mp.osd_message("Error: Could not write to " .. output_file, 2)
    end
end

-- Bind the function to a command that can be triggered by a key
mp.add_key_binding("Ctrl+j", "save-loop-to-json", save_loop_to_json)

EOT
}

check_mpv_installation
install_uosc
install_thumbfast
configure_mpv_conf
install_persist_properties
configure_input_conf
install_save_loop_to_json

echo "MPV setup complete with UOSC and Thumbfast!"
