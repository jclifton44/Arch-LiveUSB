declare -A map
echo "Reading File..."
TIFS=$IFS
IFS=$(\n)
for line in $(cat $1 | grep ".*")
do
	echo $line
	command=$(echo $line | sed -s 's/ .*$//g')
	#echo $($line | sed -s 's/ .*$//g')
	#echo $line
	#command=$($line | sed -s 's/ .*$//g')
	echo $command
	#map[$command]="true"
	#echo "entry"
	
done
IFS=$TIFS
echo $command
echo "finish parse"
for entry in $(echo ${!map[@]})
do
	echo $entry
	echo 'entry
	'
done
