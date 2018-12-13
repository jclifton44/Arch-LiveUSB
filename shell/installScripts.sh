mkdir /opt
mkdir /opt/flask
mkdir /etc/shell
cp -r ../flask/ /opt/flask
cp -r ../conf/ /etc/shell
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
