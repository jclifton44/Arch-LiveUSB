declare -A map
#echo "Reading File..."
TIFS=$IFS
IFS=""
while read line 
do
	command=$(echo $line | sed -s 's/^\s*//g' | sed -s 's/ .*$//g')

	[ ! -z $command ] && map[$command]="true"
	
done < $1
IFS=$TIFS


for entry in $(echo ${!map[@]})
do
	if [[ $entry != "" ]];
	then
		$(which $entry)
		if [[ $? -eq 0 ]];
		then
			echo $entry
		else
			echo "problem: $entry not found"
		fi

	fi
	
done
