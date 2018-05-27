echo "Before Link Down"
pwd=$(pwd)
sh "$pwd/scripts/networking/status.sh"
ip link set wlp2s0 down
echo "After Link Down"
sh "$pwd/scripts/networking/status.sh"

