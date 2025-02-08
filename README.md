# Arch Linux Install script

There are many ways to get your arch. The first one method of getting arch onto your machine is going to be through a pen drive. 
Simply insert your pen drive and run:
```
./makeArch.ps1
```
This assumes you are running a Windows environment. It will start a download of an arch ISO. Then it will mount the image, and copy the contents onto your formatted flash drive. This will only work if you are running on Windows with PowerShell. If you're execution policy disallows you from executing the script, change this with:
```
set-executionpolicy remotesigned
```
this will allow you to execute scripts in the power shell. To change this back afterwards run the following:
```
set-executionpolicy restricted
```

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
