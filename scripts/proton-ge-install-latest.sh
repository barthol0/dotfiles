#!/bin/bash
set -euo pipefail

readonly INSTALL_DIR="$HOME/.steam/root/compatibilitytools.d"
readonly TMP_DIR="/tmp/proton-ge-custom"
readonly RELEASES_API="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"

# Populated by fetch_release_info()
tarball_url=""
checksum_url=""
tarball_name=""
checksum_name=""
version_name=""

fetch_release_info() {
    echo "Fetching latest release info..."
    local release_json
    release_json=$(curl -s "$RELEASES_API")

    tarball_url=$(echo "$release_json" | grep browser_download_url | cut -d\" -f4 | grep '\.tar\.gz$' | grep -v aarch64)
    checksum_url=$(echo "$release_json" | grep browser_download_url | cut -d\" -f4 | grep '\.sha512sum$' | grep -v aarch64)

    if [[ -z "$tarball_url" || -z "$checksum_url" ]]; then
        echo "Failed to parse tarball or checksum URL from GitHub API response." >&2
        exit 1
    fi

    tarball_name=$(basename "$tarball_url")
    checksum_name=$(basename "$checksum_url")
    version_name="${tarball_name%.tar.gz}"

    echo "Latest version: $version_name"
}

confirm_reinstall_if_installed() {
    if [[ ! -d "$INSTALL_DIR/$version_name" ]]; then
        return 0
    fi

    echo "$version_name is already installed in $INSTALL_DIR."
    read -p "Do you want to reinstall it? (y/N): " reinstall
    if [[ "$reinstall" != "y" && "$reinstall" != "Y" ]]; then
        echo "Nothing to do. Exiting."
        exit 0
    fi
}

prepare_tmp_dir() {
    mkdir -p "$TMP_DIR"
    cd "$TMP_DIR"
}

cached_tarball_is_valid() {
    [[ -f "$TMP_DIR/$tarball_name" && -f "$TMP_DIR/$checksum_name" ]] || return 1
    (cd "$TMP_DIR" && sha512sum -c "$checksum_name" >/dev/null 2>&1)
}

confirm_reuse_cached() {
    echo "Cached tarball $tarball_name found in $TMP_DIR and passes checksum."
    read -p "Use it instead of re-downloading? (Y/n): " reuse
    [[ "$reuse" != "n" && "$reuse" != "N" ]]
}

download_files() {
    rm -f "$TMP_DIR/$tarball_name" "$TMP_DIR/$checksum_name"

    echo "Downloading tarball: $tarball_name..."
    curl -Lo "$tarball_name" "$tarball_url"

    echo "Downloading checksum: $checksum_name..."
    curl -Lo "$checksum_name" "$checksum_url"
}

verify_checksum() {
    echo "Verifying tarball $tarball_name with checksum $checksum_name..."
    if ! sha512sum -c "$checksum_name"; then
        echo "Checksum verification failed. The downloaded tarball may be corrupted." >&2
        exit 1
    fi
}

ensure_tarball_ready() {
    if cached_tarball_is_valid && confirm_reuse_cached; then
        echo "Reusing cached tarball."
        return
    fi
    download_files
    verify_checksum
}

install_tarball() {
    mkdir -p "$INSTALL_DIR"

    if [[ -d "$INSTALL_DIR/$version_name" ]]; then
        echo "Removing existing $version_name installation..."
        rm -rf "$INSTALL_DIR/$version_name"
    fi

    echo "Extracting $tarball_name to $INSTALL_DIR..."
    tar -xf "$tarball_name" -C "$INSTALL_DIR/"
}

main() {
    fetch_release_info
    confirm_reinstall_if_installed
    prepare_tmp_dir
    ensure_tarball_ready
    install_tarball
    echo "ALL DONE. Installed $version_name to $INSTALL_DIR."
}

main "$@"
