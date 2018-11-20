name="shell-scripts-source"
mkdir $name
cd $name
mkdir conf
mkdir shell
while read line
do
	cp /usr/bin/$line shell/$line.sh
	
done < /etc/shell/installedFiles
cp -r /etc/shell/* conf
rm -rf conf/installedFiles
cd ../
tar -zcvf compressed-shell-scripts-source.tar.gz $name
rm -rf $name
