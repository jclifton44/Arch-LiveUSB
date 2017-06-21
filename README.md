# Arch Linux Install script
Installs packages with TLS/SSL and signing from Arch package servers

1. Before installation open install.sh and make sure SWAP, ROOT, and BOOT/UEFI are set.

Example:
SWAP: /dev/sda8
ROOT: /dev/sda6
BOOT: /dev/sda2

2. Change WPA2 network connection in /scripts/networking/startWPA2Wireless.sh

SSID="service set identifier"
PSK="privately shared key"

3. Load alongside a LIVE USB or CD and execute:
install.sh

4. Reboot
Login: root
no password
