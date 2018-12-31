echo $1
echo $1 | grep "^\s*{" | grep "}\s*$" 
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
		#key=$(echo $kvPair | sed "s/:.*$//g")
		#value=$(echo $kvPair | sed "s/^[^:]*://g")
		#echo "KEY: $key"
		#echo "VALUE: $value"
	done
else
	echo $1 | grep "^\s*\[" | grep "\]\s*$" >> /dev/null
	if [ $? -eq 0 ];
	then	
		echo message
		#json array
	else
		echo message
		#json string
	fi

fi

