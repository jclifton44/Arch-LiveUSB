killall wpa_supplicant
startWPA2Wireless
dhcpcd
sleep 3
echo "ip lease"
tableOff
linkup
git clone $1
tableOn
linkdown



