echo "Before Link Down"
pwd=$(pwd)
status
ip link set wlp2s0 down
killall wpa_supplicant
echo "After Link Down"
status

