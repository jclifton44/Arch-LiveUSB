dev=$(sh getinterface.sh)
echo "Device: $dev"
mac=$(cat /sys/class/net/$dev/address)
echo "MAC: $mac"
#tcpdump -ve ether host $mac 
tcpdump -evvl ether host $mac | while read out; do
	echo "$out"
	outarray=($out)
	echo ${outarray[1]}	
done
