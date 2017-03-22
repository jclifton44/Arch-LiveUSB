echo "Before Link Down"
sh status.sh
ip link set wlp2s0 down
echo "After Link Down"
sh status.sh
