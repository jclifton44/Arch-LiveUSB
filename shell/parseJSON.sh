echo $@
if [ -z $2 ]; then
	echo $1
	exit
fi
echo $1 | grep "^\s*{" | grep "}\s*$"  >> /dev/null
if [ $? -eq 0 ];
then
	jsonObjectList=$(echo $1 | sed "s/^\s*{//g" | sed "s/}\s*$//")
	while [[ ${#jsonObjectList} > 0 ]];
	do
		echo $jsonObjectList | grep "^\s*\"[^\"]*\"\s*:\s*{" >> /dev/null
		if [ $? -eq 0 ];
		then
			invertedKvPair=$(echo $jsonObjectList | sed "s/^\s*\".*\"\s*:\s*{.*}\s*,//")
			kvPair=$(echo $jsonObjectList | sed "s/$invertedKvPair//g")
			kvPair=$(echo $kvPair | sed "s/,\s*$//")
			jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*\".*\"\s*:\s*{.*}\s*,//")
		else
			echo $jsonObjectList | grep "^\s*\"[^\"]*\"\s*:\s*\[" >> /dev/null
			if [ $? -eq 0 ];
			then
				kvPair=$(echo $jsonObjectList | sed "s/,.*$//g")
				jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*\".*\"\s*:\s*\[.*\]\s*,//")
			else
				echo $jsonObjectList | grep "^\s*\".*\"\s*:\s*\"" >> /dev/null
				if [ $? -eq 0 ];
				then
					kvPair=$(echo $jsonObjectList | sed "s/,.*$//g")
					jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*$kvPair//g")
					jsonObjectList=$(echo $jsonObjectList | sed "s/^\w*,//g")
				fi
			fi
		fi


		#echo $kvPair
		key=$(echo $kvPair | sed "s/:.*$//g")
		value=$(echo $kvPair | sed "s/^[^:]*://g")
		#echo "KEY: $key"
		#echo "VALUE: $value"
		if [ $2 == $key ];
		then	
			shift
			shift
			arguments=($value ${@[@]})
			./parseJSON.sh $arguments
		fi
	done
else
	echo $1 | grep "^\s*\[" | grep "\]\s*$" >> /dev/null
	if [ $? -eq 0 ];
	then	
		jsonArray=$(echo $1 | sed "s/^\s*\[//" | sed "s/\]\s*$//")
		echo $jsonArray
		counter=0
		while [[ ${#jsonArray} > 0 ]];
		do
			echo $jsonArray | grep "^\s*{" >> /dev/null
			if [ $? -eq 0 ];
			then
				brackets=0
				firstBracket="false"
				bracketIndex=0
				for (( i=0; i < ${#jsonArray}; i=$((i+1)) ))
				do
					if [ "${jsonArray:$i:1}" == "{" ]; then
						firstBracket="true"
						brackets=$((brackets+1))
					fi
					if [ "${jsonArray:$i:1}" == '}' ]; then
						brackets=$((brackets-1))
					fi
					if [ $firstBracket == 'true' ] && [ $brackets -eq 0 ];
					then
						bracketIndex=$i
						break;
					fi

				done
				jsonArrayElement=$(echo "${jsonArray:0:$((bracketIndex + 1))}")
				echo $jsonArrayElement
				newLength=${#jsonArray}
				newLength=$((newLength-bracketIndex))
				jsonArray=$(echo "${jsonArray:$((bracketIndex+1)):$newLength}")
				jsonArray=$(echo $jsonArray | sed "s/^\s*,\s*//")
				echo $jsonArray
			else
				echo "array"
				echo $jsonArray | grep "^\s*\[" >> /dev/null
				if [ $? -eq 0 ];
				then
					brackets=0
					firstBracket="false"
					bracketIndex=0
					for (( i=0; i < ${#jsonArray}; i=$((i+1)) ))
					do
						if [ "${jsonArray:$i:1}" == "[" ]; then
							firstBracket="true"
							brackets=$((brackets+1))
						fi
						if [ "${jsonArray:$i:1}" == ']' ]; then
							brackets=$((brackets-1))
						fi
						if [ $firstBracket == 'true' ] && [ $brackets -eq 0 ];
						then
							bracketIndex=$i
							break;
						fi

					done

					jsonArrayElement=$(echo "${jsonArray:0:$((bracketIndex + 1))}")
					echo $jsonArrayElement
					newLength=${#jsonArray}
					newLength=$((newLength-bracketIndex))
					jsonArray=$(echo "${jsonArray:$((bracketIndex+1)):$newLength}")
					jsonArray=$(echo $jsonArray | sed "s/^\s*,\s*//")
					echo $jsonArray

				else
					echo $jsonArray | grep "" >> /dev/null
					if [ $? -eq 0 ];
					then
						kvPair=$(echo $jsonArray | sed "s/,.*$//g")
						jsonObjectList=$(echo $jsonArray | sed "s/^\s*$kvPair//g")
						jsonObjectList=$(echo $jsonArray | sed "s/^\w*,//g")
					fi
				fi
			fi
	
	
			#echo $kvPair
			key=$(echo $kvPair | sed "s/:.*$//g")
			value=$(echo $kvPair | sed "s/^[^:]*://g")
			#echo "KEY: $key"
			#echo "VALUE: $value"
			if [ $2 -eq $counter ];
			then	
				shift
				shift
				arguments=($value $@)
				./parseJSON.sh $arguments
			fi
			counter=$((counter+1))
		done
	
		#json array
	fi

fi

