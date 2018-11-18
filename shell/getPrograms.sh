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


declare -A packageDeps

for entry in $(echo ${!map[@]})
do
	if [[ $entry != "" ]];
	then
		which $entry &> /dev/null
		if [[ $? -eq 0 ]];
		then
			#echo $entry
			#echo $?
			pacman -Qo $entry &> /dev/null
			if [[ $? -eq 0 ]];
			then
				ownership=$(pacman -Qo $entry | sed -s 's/^.*owned by //g')
				packageDeps[${ownership/ /=}]="true"
				#echo ${ownership/ /=}
				
				
			else 
				deps=$(getPrograms $(which $entry))
				for dependency in ${deps[@]}
				do
					packageDeps[$dependency]="true"
				done
			fi
		fi

	fi
	
done
echo ${!packageDeps[@]}
