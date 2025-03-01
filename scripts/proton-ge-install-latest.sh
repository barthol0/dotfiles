#!/bin/bash
set -euo pipefail

# make temp working directory
echo "Creating temporary working directory..."
rm -rf /tmp/proton-ge-custom
mkdir /tmp/proton-ge-custom
cd /tmp/proton-ge-custom

# fetch tarball and checksum URLs
echo "Fetching tarball URL..."
tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
tarball_name=$(basename "$tarball_url")

echo "Fetching checksum URL..."
checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
checksum_name=$(basename "$checksum_url")

# check if tarball already exists
if [[ -f ~/.steam/root/compatibilitytools.d/"$tarball_name" ]]; then
    echo "Tarball $tarball_name already exists in Steam directory."
    
    # verify checksum
    echo "Verifying checksum of existing tarball..."
    (cd ~/.steam/root/compatibilitytools.d/ && sha512sum -c "$checksum_name" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        echo "Checksum verification successful. The existing tarball is valid."
        read -p "Do you want to download the tarball anyway? (y/n): " download_anyway
        if [[ "$download_anyway" != "y" ]]; then
            echo "Exiting script."
            exit 0
        fi
    else
        echo "Checksum verification failed. The existing tarball may be corrupted."
        read -p "Do you want to download the tarball again? (y/n): " download_again
        if [[ "$download_again" != "y" ]]; then
            echo "Exiting script."
            exit 0
        fi
    fi
fi

# download tarball
echo "Downloading tarball: $tarball_name..."
curl -Lo "$tarball_name" "$tarball_url"

# download checksum
echo "Downloading checksum: $checksum_name..."
curl -Lo "$checksum_name" "$checksum_url"

# verify tarball with checksum
echo "Verifying tarball $tarball_name with checksum $checksum_name..."
sha512sum -c "$checksum_name"
if [[ $? -ne 0 ]]; then
    echo "Checksum verification failed. The downloaded tarball may be corrupted."
    exit 1
fi

# make steam directory if it does not exist
echo "Creating Steam directory if it does not exist..."
mkdir -p ~/.steam/root/compatibilitytools.d

# extract proton tarball to steam directory
echo "Extracting $tarball_name to Steam directory..."
tar -xf "$tarball_name" -C ~/.steam/root/compatibilitytools.d/
echo "ALL DONE."