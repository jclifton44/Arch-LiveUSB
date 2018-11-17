if [[ $1 == "" ]]; 
then
	echo "Please specify a package"
	exit
fi

echo "Checking Dependencies: $1"
declare -A map
findDeps() {
	j=0
	for i in $(pacman -Qi $1 | grep -Eo 'Depends.*'); do
		if (( j++ > 2 )); 
		then
			if [[ $i != "None" ]]
			then
				map[$i]="true"
				for d in $(findDeps $i $2); do
					map[$d]="true"
				done
			fi
		fi

	done		
	echo ${!map[@]}
}
for dependency in $(findDeps $1 map); do
	echo $dependency
done

