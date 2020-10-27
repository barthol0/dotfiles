#!/bin/bash

# Update and install basic packages
sudo apt update -y &&
sudo apt upgrade -y &&
sudo apt install -y vim git tmux zsh &&

# Additional packages
sudo apt install -y python-dev python-psutil build-essential python3-pip bpython3

#
pip install --user pipx
pipx install pipenv

# zsh + oh-my-zsh
sudo apt -y install zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Fix freezing ssh
sudo bash -c 'echo "IPQoS cs0 cs0" >> /etc/ssh/sshd_config'
sudo bash -c 'echo "IPQoS cs0 cs0" >> /etc/ssh/ssh_config'

# Disable power saving
printf "# Disable power saving\n
options 8192cu rtw_power_mgnt=0 rtw_enusbss=1 rtw_ips_mode=1" >> "/etc/modprobe.d/8192cu.conf"

sudo reboot