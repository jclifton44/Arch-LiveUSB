mkdir /opt
mkdir /opt/flask
mkdir /etc/shell
cp -r ../flask/ /opt
cp -r ../conf/ /etc/shell
for line in $(ls); do 
	cp $line /usr/bin/$(echo $line | sed -s 's/\.sh//g') 
	echo $line | sed -s 's/\.sh//g' >> /etc/shell/installedFiles

done
if [ $1 == '-r' ]; then	
	cd remote
	echo "Installing Remote"
	for line in $(ls); do 
		cp $line /usr/bin/$(echo $line | sed -s 's/\.sh//g') 
		echo $line | sed -s 's/\.sh//g' >> /etc/shell/installedFiles

	done
	cd ../
else
	echo "Non-remote installation"
fi
