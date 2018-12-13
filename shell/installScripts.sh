cp -r ../conf/ /etc/shell
mkdir /opt
cp -r ../flask/ /opt/flask
for line in $(ls); do 
	cp $line /usr/bin/$(echo $line | sed -s 's/\.sh//g') 
	echo $line | sed -s 's/\.sh//g' >> /etc/shell/installedFiles

done
cd remote
for line in $(ls); do 
	cp $line /usr/bin/$(echo $line | sed -s 's/\.sh//g') 
	echo $line | sed -s 's/\.sh//g' >> /etc/shell/installedFiles

done
cd ../
