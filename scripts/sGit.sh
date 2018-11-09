cd networking
./startWPA2Wireless.sh
dhcpcd
ping -c3 8.8.8.8
sleep 3
echo "sleep"
cd ../
networking/tableOff.sh
git clone $1
networking/tableOn.sh
networking/linkdown.sh



