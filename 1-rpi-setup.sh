#!/bin/bash

PATH_TO_BOOT="/run/media/bartholo/boot/"
FILE="${PATH_TO_BOOT}wpa_supplicant.conf"

cd $PATH_TO_BOOT

# enable UART
printf "\nenable_uart=1" >> config.txt
# enable SSH
touch "${PATH_TO_BOOT}ssh"

if test -f "$FILE"; then
    echo "#################### $FILE exist"
else
    printf "country=UK
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1
    network={
        ssid=\"WIFI_NAME\"
        psk=\"WIFI_PASSWORD\"
        key_mgmt=WPA-PSK
    }" >> wpa_supplicant.conf
fi
