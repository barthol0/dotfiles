# This is a script to fix Fn+F1...12 combination keys aka media keys on Drevo Calibur V2 Keyboard
# 
# Tested on: Manjaro Linux
#
# Original author: https://github.com/marzeq/drevo-calibur-2-linux-fnkeys
#

# For current session

echo 0 | sudo tee /sys/module/hid_apple/parameters/fnmode

# For after reboot

echo options hid_apple fnmode=0 | sudo tee -a /etc/modprobe.d/hid_apple.conf

if command -v mkinitcpio &> /dev/null

then
    
    sudo mkinitcpio -P
    
elif command -v update-initramfs &> /dev/null

then
    
    sudo update-initramfs -u
    
else
    
    echo "Could not find mkinitcpio or update-initramfs. Please a find an alternative for your distribution."
    
fi
