echo "Before Link Down"
pwd=$(pwd)
sh "$pwd/scripts/networking/status.sh"
ip link set wlp2s0 down
killall wpa_supplicant
echo "After Link Down"
sh "$pwd/scripts/networking/status.sh"

