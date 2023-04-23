#!/bin/bash

echo "CPU Information:"
echo "================="
lscpu
echo ""

echo "Memory Information:"
echo "==================="
free -h
echo ""

echo "Disk Space and Usage:"
echo "====================="
df -h
echo ""

echo "System and Hardware Information:"
echo "================================"
sudo lshw
echo ""

echo "PCI Devices:"
echo "============"
lspci
echo ""

echo "USB Devices:"
echo "==========="
lsusb
echo ""

echo "Linux Kernel Version and System Information:"
echo "============================================"
uname -a
echo ""
