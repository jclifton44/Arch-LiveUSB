cd networking
./startWPA2Wireless.sh
dhcpcd
sleep 3
echo "ip lease"
cd ../
networking/tableOff.sh
networking/linkup.sh
git clone $1
networking/tableOn.sh
networking/linkdown.sh



