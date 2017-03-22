echo "Before Link Up"
sh status.sh
ip link set wlp2s0 up
echo "After Link Up"
sh status.sh
