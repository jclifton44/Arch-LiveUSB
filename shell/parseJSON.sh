if [ $# -eq 1 ]; then
	returnJson=""
	echo $1 | grep "^\".*\"$" >> /dev/null
	if [ $? -eq 0 ];
	then
		returnJson=$(echo $1 | sed "s/^\"//g" | sed "s/\"$//g")
	else
		returnJson=$1
	fi
	echo $returnJson
	exit
fi

echo $1 | grep "^\s*{" | grep "}\s*$"  >> /dev/null
if [ $? -eq 0 ];
then
	jsonObjectList=$(echo $1 | sed "s/^\s*{//g" | sed "s/}\s*$//")
	noMatch="true"
	initialJsonObjectList=$jsonObjectList
	while [ ${#jsonObjectList} -gt 0 ];
	do
		firstDoubleQuote="false"
		quoteIndex=0
		for (( i=0; i < ${#jsonObjectList}; i=$((i+1)) ))
		do
			if [ "${jsonObjectList:$i:1}" == "\"" ] && [ $firstDoubleQuote == "true" ]; then
				if [ "${jsonObjectList:$((i-1)):1}" != "\\" ]; then
					quoteIndex=$i
					firstDoubleQuote="false"
					break
				fi
			fi
			if [ "${jsonObjectList:$i:1}" == "\"" ] && [ $firstDoubleQuote == "false" ]; then
				firstDoubleQuote="true"
			fi
		done

		key=$(echo "${jsonObjectList:0:$((quoteIndex + 1))}")
	

		nextLength=${#jsonObjectList}
		nextLength=$((nextLength-quoteIndex))
		jsonObjectList=$(echo "${jsonObjectList:$((quoteIndex+1)):$nextLength}")
		jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*\:\s*//")
		echo $jsonObjectList | grep "^\s*{" >> /dev/null
		if [ $? -eq 0 ];
		then
			brackets=0
			firstBracket="false"
			bracketIndex=0
			firstDoubleQuote="false"
			for (( i=0; i < ${#jsonObjectList}; i=$((i+1)) ))
			do


				if [ $firstDoubleQuote == "true" ] || [ "${jsonObjectList:$i:1}" == "\"" ] && [ "$firstDoubleQuote" == "false" ]; then
					firstDoubleQuote="true"
					if [ "${jsonObjectList:$i:1}" == "\"" ] && [ $firstDoubleQuote == "true" ]; then
						if [ "${jsonObjectList:$((i-1)):1}" != "\\" ]; then
							firstDoubleQuote="false"
						fi
					fi
				fi


				if [ "${jsonObjectList:$i:1}" == "{" ]; then
					firstBracket="true"
					if [ $firstDoubleQuote == "false" ]; then
						brackets=$((brackets+1))
					fi
				fi
				if [ "${jsonObjectList:$i:1}" == '}' ]; then
					if [ $firstDoubleQuote == "false" ]; then
						brackets=$((brackets-1))
					fi
				fi
				if [ $firstBracket == 'true' ] && [ $brackets -eq 0 ];
				then
					bracketIndex=$i
					break;
				fi
			done
			value=$(echo "${jsonObjectList:0:$((bracketIndex + 1))}")
			nextLength=${#jsonObjectList}
			nextLength=$((nextLength-bracketIndex))
			jsonObjectList=$(echo "${jsonObjectList:$((bracketIndex+1)):$nextLength}")
			jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*,\s*//")

		else
			echo $jsonObjectList | grep "^\s*\[" >> /dev/null
			if [ $? -eq 0 ];
			then

				brackets=0
				firstBracket="false"
				bracketIndex=0
				firstDoubleQuote="false"
				for (( i=0; i < ${#jsonObjectList}; i=$((i+1)) ))
				do

					if [ $firstDoubleQuote == "true" ] || [ "${jsonObjectList:$i:1}" == "\"" ] && [ "$firstDoubleQuote" == "false" ]; then
						firstDoubleQuote="true"
						if [ "${jsonObjectList:$i:1}" == "\"" ] && [ $firstDoubleQuote == "true" ]; then
							if [ "${jsonObjectList:$((i-1)):1}" != "\\" ]; then
								firstDoubleQuote="false"
							fi
						fi
					fi

					if [ "${jsonObjectList:$i:1}" == "[" ]; then
						firstBracket="true"
						if [ $firstDoubleQuote == "false" ]; then
							brackets=$((brackets+1))
						fi
					fi
					if [ "${jsonObjectList:$i:1}" == ']' ]; then
						if [ $firstDoubleQuote == "false" ]; then
							brackets=$((brackets-1))
						fi
					fi
					if [ $firstBracket == 'true' ] && [ $brackets -eq 0 ];
					then
						bracketIndex=$i
						break;
					fi
				done
				value=$(echo "${jsonObjectList:0:$((bracketIndex + 1))}")
				nextLength=${#jsonObjectList}
				nextLength=$((nextLength-bracketIndex))
				jsonObjectList=$(echo "${jsonObjectList:$((bracketIndex+1)):$nextLength}")
				jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*,\s*//")

			else
				echo $jsonObjectList | grep "^\s*\"" >> /dev/null
				if [ $? -eq 0 ];
				then
					firstDoubleQuote="false"
					quoteIndex=0
					for (( i=0; i < ${#jsonObjectList}; i=$((i+1)) ))
					do
						if [ "${jsonObjectList:$i:1}" == "\"" ] && [ $firstDoubleQuote == "true" ]; then
							if [ "${jsonObjectList:$((i-1)):1}" != "\\" ]; then
								quoteIndex=$i
								firstDoubleQuote="false"
								break
							fi
						fi
						if [ "${jsonObjectList:$i:1}" == "\"" ] && [ $firstDoubleQuote == "false" ]; then
							firstDoubleQuote="true"
						fi
					done
					value=$(echo "${jsonObjectList:0:$((quoteIndex + 1))}")

					nextLength=${#jsonObjectList}
					nextLength=$((nextLength-quoteIndex))
					jsonObjectList=$(echo "${jsonObjectList:$((quoteIndex+1)):$nextLength}")
					jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*,\s*//")

				else
					echo $jsonObjectList | grep "^\s*[0-9]\{1,\}\s*" >> /dev/null
					if [ $? -eq 0 ];
					then
						value=$(echo $jsonObjectList | sed "s/,.*//g")
						jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*$value\s*//g")
						jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*,\s*//g")
					else
						echo $jsonObjectList | grep "^\s*true*\s*" >> /dev/null
						if [ $? -eq 0 ]; then
							value="true"
							jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*true\s*,//g")
						fi
						echo $jsonObjectList | grep "^\s*false*\s*" >> /dev/null
						if [ $? -eq 0 ]; then
							value="false"
							jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*false\s*,//g")
						fi
						echo $jsonObjectList | grep "^\s*null*\s*" >> /dev/null
						if [ $? -eq 0 ]; then
							value="null"
							jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*null\s*,//g")
						fi

					fi



					#check for digit or boolean
				fi
			fi
		fi


		#echo $kvPair
		#echo "KEY: $key"
		#echo "VALUE: $value"
		key=$(echo $key | sed "s/^\s*//" | sed "s/\s*$//")
		#echo $value
		#value=$(echo $value | sed 's/\"/\\\"/g')
		matchingKey=$(echo $2 | sed "s/\"/\\\"/")
		#echo "RETVAL: $value"	
		if [ "\"$2\"" == "$key" ];
		then	
			noMatch="false"
			if [ "$value" == "" ]; then
				echo "error: json formatting error"
				exit 1
			fi
			shift
			shift
			arguments=("$value $@")
			./parseJSON.sh "$value" $@
			exit
		fi
	done
	if [ $noMatch == "true" ]; then
		echo "error: no matching key: key $2 of object $initialJsonObjectList"
		exit 1
	fi
else
	echo $1 | grep "^\s*\[" | grep "\]\s*$" >> /dev/null
	if [ $? -eq 0 ];
	then	
		
		counter=0
		jsonArray=$(echo $1 | sed "s/^\s*\[//" | sed "s/\]\s*$//")
		initialJsonArray=$jsonArray
		while [ ${#jsonArray} -gt 0 ];
		do
			echo $jsonArray | grep "^\s*{" >> /dev/null
			if [ $? -eq 0 ];
			then
				brackets=0
				firstBracket="false"
				bracketIndex=0
				firstDoubleQuote="false"
				for (( i=0; i < ${#jsonArray}; i=$((i+1)) ))
				do


					if [ $firstDoubleQuote == "true" ] || ( [ "${jsonArray:$i:1}" == "\"" ] && [ $firstDoubleQuote == "false" ] ); then
						firstDoubleQuote="true"
						if [ "${jsonArray:$i:1}" == "\"" ] && [ $firstDoubleQuote == "true" ]; then
							if [ "${jsonObjectList:$((i-1)):1}" != "\\" ]; then
								firstDoubleQuote="false"
							fi
						fi
					fi


					if [ "${jsonArray:$i:1}" == "{" ]; then
						firstBracket="true"
						if [ $firstDoubleQuote == "false" ]; then
							brackets=$((brackets+1))
						fi
					fi
					if [ "${jsonArray:$i:1}" == '}' ]; then
						
						if [ $firstDoubleQuote == "false" ]; then
							brackets=$((brackets-1))
						fi
					fi
					if [ $firstBracket == 'true' ] && [ $brackets -eq 0 ];
					then
						bracketIndex=$i
						break;
					fi

				done
				key=$(echo "${jsonArray:0:$((bracketIndex + 1))}")
				nextLength=${#jsonArray}
				nextLength=$((nextLength-bracketIndex))
				jsonArray=$(echo "${jsonArray:$((bracketIndex+1)):$nextLength}")
				jsonArray=$(echo $jsonArray | sed "s/^\s*,\s*//")
			else
				
				echo $jsonArray | grep "^\s*\[" >> /dev/null
				if [ $? -eq 0 ];
				then
					brackets=0
					firstBracket="false"
					bracketIndex=0
					firstDoubleQuote="false"
					for (( i=0; i < ${#jsonArray}; i=$((i+1)) ))
					do
						if [ $firstDoubleQuote == "true" ] || ( [ "${jsonArray:$i:1}" == "\"" ] && [ "$firstDoubleQuote" == "false" ] ); then
							firstDoubleQuote="true"
							if [ "${jsonArray:$i:1}" == "\"" ] && [ $firstDoubleQuote == "true" ]; then
								if [ "${jsonObjectList:$((i-1)):1}" != "\\" ]; then
									firstDoubleQuote="false"
								fi
							fi
						fi

						if [ "${jsonArray:$i:1}" == "[" ]; then
							firstBracket="true"
							if [ $firstDoubleQuote == "false" ]; then
								brackets=$((brackets+1))
							fi
						fi
						if [ "${jsonArray:$i:1}" == ']' ]; then
							if [ $firstDoubleQuote == "false" ]; then
								brackets=$((brackets-1))
							fi
						fi
						if [ $firstBracket == 'true' ] && [ $brackets -eq 0 ];
						then
							bracketIndex=$i
							break;
						fi

					done
					key=$(echo "${jsonArray:0:$((bracketIndex + 1))}")
					nextLength=${#jsonArray}
					nextLength=$((nextLength-bracketIndex))
					jsonArray=$(echo "${jsonArray:$((bracketIndex+1)):$nextLength}")
					jsonArray=$(echo $jsonArray | sed "s/^\s*,\s*//")
					

				else
					
					echo $jsonArray | grep "^\s*\"" >> /dev/null
					if [ $? -eq 0 ]; then
						firstDoubleQuote="false"
						quoteIndex=0
						for (( i=0; i < ${#jsonArray}; i=$((i+1)) ))
						do
							if [ "${jsonArray:$i:1}" == "\"" ] && [ $firstDoubleQuote == "true" ]; then
								if [ "${jsonObjectList:$((i-1)):1}" != "\\" ]; then
									quoteIndex=$i
									firstDoubleQuote="false"
									break
								fi
							fi
							if [ "${jsonArray:$i:1}" == "\"" ] && [ $firstDoubleQuote == "false" ]; then
								firstDoubleQuote="true"
							fi
						done

						key=$(echo "${jsonArray:0:$((quoteIndex + 1))}")
						nextLength=${#jsonArray}
						nextLength=$((nextLength-quoteIndex))
						jsonArray=$(echo "${jsonArray:$((quoteIndex+1)):$nextLength}")
						jsonArray=$(echo $jsonArray | sed "s/^\s*\,\s*//")
					else
						echo $jsonArray | grep "^\s*[0-9]\{1,\}\s*" >> /dev/null
						if [ $? -eq 0 ];
						then
							key=$(echo $jsonArray | sed "s/,.*//g")
							jsonArray=$(echo $jsonArray | sed "s/^\s*$key\s*//g")
							jsonArray=$(echo $jsonArray | sed "s/^\s*,\s*//g")
						else
							echo $jsonArray | grep "^\s*true*\s*" >> /dev/null
							if [ $? -eq 0 ]; then
								key="true"
								jsonArray=$(echo $jsonArray | sed "s/^\s*true\s*,//g")
							fi
							echo $jsonArray | grep "^\s*false*\s*" >> /dev/null
							if [ $? -eq 0 ]; then
								key="false"
								jsonArray=$(echo $jsonArray | sed "s/^\s*false\s*,//g")
							fi
							echo $jsonArray | grep "^\s*null*\s*" >> /dev/null
							if [ $? -eq 0 ]; then
								key="null"
								jsonArray=$(echo $jsonArray | sed "s/^\s*null\s*,//g")
							fi
	
						fi


					fi

						
				fi
			fi
	
	
			#echo $kvPair
			#echo "KEY: $key"
			#echo "VALUE: $value"



			key=$(echo $key | sed "s/^\s*//" | sed "s/\s*$//")
			#echo "COUNTER:"
			#echo "KEY: $key"
			#echo "VALUE: $value"
			#echo $counter	
			#echo $2
			if [ $2 -eq $counter ];
			then	
				shift
				shift
				./parseJSON.sh "$key" $@
				exit
			fi


			counter=$((counter+1))
		done
		counter=$((counter-1))
		if [ $counter -lt $2 ]; then
			echo "error: array index out of bounds: index $2 of array $initialJsonArray"
			exit 1
		fi
	
		#json array
	fi

fi

