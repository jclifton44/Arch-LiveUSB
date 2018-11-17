startWPA2Wireless
dhcpcd
sleep 3
echo "ip lease"
tableOff
networking/linkup
git clone $1
tableOn
linkdown



