#This script connects you to a wifi-router named ssid with psk and disables your ipv6
#To reenable IPv6 remove the first line from /proc/sys/net/ipv6/<dev>/disable_ipv6
dev=$(sh getInterface.sh)
echo "interface:"
echo $iface
sh status.sh
sleep 5
echo "Shutting all ports..."
iptables -P INPUT DROP

#Two processes cannot be trying to access the network card at the same time
#Disable DHCPCD
systemctl stop dhcpcd
#Stop existing threads of wpa_supplicant
killall wpa_supplicant

ssid="The Clubhouse WiFi"
psk="chwifi2015"
echo "Using ssid: '$ssid'"
echo "Using psk: '$psk'"
echo ""
sh status.sh
#iw dev $dev link
#iw dev $dev set type ibss
#echo "Set type to ibss"
rm -rf wpa2.conf
wpa_passphrase "$ssid" "$psk" >> wpa2.conf
wpa_supplicant -D nl80211,wext -i $dev -c wpa2.conf  -B
sleep 5
echo ""
sh status.sh
rm -rf wpa2.conf
#echo "Disabling IPV6"
echo ""
#temporary disable
echo 1 > /proc/sys/net/ipv6/conf/$dev/disable_ipv6
#sh status.sh

