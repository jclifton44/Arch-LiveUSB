#/bin/bash

echo "Starting graphical user interface - Desktop Environment"

#gui
systemctl start gdm.service

#networkmanager
systemctl stop dhcpcd@.service
systemctl stop dhcpcd.service
#ip link set down wlp2s0
systemctl start NetworkManager.service
