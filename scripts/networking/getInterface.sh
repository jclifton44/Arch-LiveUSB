#/bin/bash
pattern="eth"

for d in /sys/class/net/*/ ; do
	dir=$(basename $d)
	if [[ "$dir" != "lo" && ! "$dir" =~ "$pattern" ]] ; then
		export iface="$dir"		
	fi

done
echo $iface
