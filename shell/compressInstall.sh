name="shell-scripts-source"
mkdir $name
cd $name
mkdir conf
mkdir shell
while read line
do
	cp /usr/bin/$line.sh shell/
done < /etc/shell/installedFiles
cp -r /etc/shell/* conf
rm -rf conf/installedFiles
cd ../
tar -cfv shell-scripts-source
rm -rf $name
