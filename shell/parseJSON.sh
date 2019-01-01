if [ $# -eq 1 ]; then
	echo $1
	exit
fi
echo $1 | grep "^\s*{" | grep "}\s*$"  >> /dev/null
if [ $? -eq 0 ];
then
	jsonObjectList=$(echo $1 | sed "s/^\s*{//g" | sed "s/}\s*$//")
	while [[ ${#jsonObjectList} > 0 ]];
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
					jsonObjectList=$(echo $jsonObjectList | sed "s/^\s*\:\s*//")

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
			shift
			shift
			arguments=("$value $@")
			./parseJSON.sh "$value" $@
			exit
		fi
	done
else
	echo $1 | grep "^\s*\[" | grep "\]\s*$" >> /dev/null
	if [ $? -eq 0 ];
	then	
		jsonArray=$(echo $1 | sed "s/^\s*\[//" | sed "s/\]\s*$//")
		counter=0
		while [[ ${#jsonArray} > 0 ]];
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
							echo $bracketIndex
							break;
						fi

					done
					key=$(echo "${jsonArray:0:$((bracketIndex + 1))}")
					nextLength=${#jsonArray}
					nextLength=$((nextLength-bracketIndex))
					jsonArray=$(echo "${jsonArray:$((bracketIndex+1)):$nextLength}")
					jsonArray=$(echo $jsonArray | sed "s/^\s*,\s*//")
					

				else

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
	
		#json array
	fi

fi

