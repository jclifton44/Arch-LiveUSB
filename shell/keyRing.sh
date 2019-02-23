

listFlag="false"
addFlag="false"
removeFlag="false"
touch /etc/shell/keyRingList
mkdir -p /etc/shell/keys
for i in "$@"
do	
	case $1 in
		--list*)
			echo "Key list:"
			listFlag="true"
			break
		;;
		--add)
			echo "Key add:"
			addFlag="true"
			keyName="$2"
			break
		;;
		--remove)
			echo "Key remove:"
			removeFlag="true"
			keyName="$2"
			break
	esac
done
if [[ $listFlag == "true" ]];
then
	cat /etc/shell/keyRingList

fi

if [[ $addFlag == "true" ]];
then
	serverProtocol=$(./urlParser.sh $keyName | awk '{ print $1 }')
	serverFQDN=$(./urlParser.sh $keyName | awk '{ print $2 }')
	serverPath=$(./urlParser.sh $keyName | awk '{ print $3 }')
	cat /etc/shell/keyRingList | grep $serverFQDN >> /dev/null
	if [[ $? -ne 0 ]];
	then 
		#$(echo $serverFQDN | sed "s/\..*$//g")
		echo sendable | openssl s_client -servername $serverFQDN -connect $serverFQDN:443 >> /etc/shell/keys/$(echo $serverFQDN | sed "s/\..*$//g").crt
		echo $serverFQDN >> /etc/shell/keyRingList
	else
		echo "Key already in key ring. Exiting."
	fi


fi

if [[ $removeFlag == "true" ]];
then
	cat /etc/shell/keyRingList | grep $keyName >> /dev/null
	if [[ $? -ne 0 ]];
	then
		echo "Key not in key ring. Exiting."
	else
		sed -i "s/$keyName//g" /etc/shell/keyRingList
		rm /etc/shell/keys/$(echo $keyName | sed "s/\..*$//g").crt
	fi

fi
