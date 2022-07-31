#!/bin/bash

PATH_TO_BOOT="<PATH_TO_BOOT_PARTITION>" # ie /run/media/joe/boot
FILE="${PATH_TO_BOOT}/wpa_supplicant.conf"
SSID='<YOUR_SSID>'
PASSWORD='<YOUR_PASSWORD>'

cd $PATH_TO_BOOT

# enable UART
printf "\nenable_uart=1" >> config.txt

# enable SSH
touch "${PATH_TO_BOOT}/ssh"

# set default ssh username/password
# consisting of username:encrypted-password
# https://discourse.pi-hole.net/t/warning-latest-raspberry-pi-os-image-april-4th-2022/54778/2
# to generate hash: openssl passwd -6 -stdin <<< 'rasp'
# pi:rasp
echo 'pi:$6$woaQGC163nMsoCuh$v/JFqJULKrw94B4bA3kSOFVv.5iVMUDK5hbPeBsoOAGfky0T6huHM794xyXBM20zGBz8J.8cO0OF57HQyo1uQ0' >> "${PATH_TO_BOOT}/userconf"

if test -f "$FILE"; then
    echo "#################### $FILE exist"
else
    printf '%s\n' "country=UK
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1
    network={
        ssid=\"$SSID\"
        psk=\"$PASSWORD\"
        key_mgmt=WPA-PSK
    }" >> wpa_supplicant.conf
fi
