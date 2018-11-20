while read line
do 
	rm /usr/bin/$(echo $line | sed -s 's/\.sh//g') 
done < /etc/shell/installedFiles
rm -rf /etc/shell

