serverName=$1
writeCommit="false"
pageVisit="false"
recentCommit="false"
for i in "$@"
do	
	case $1 in
		--writeCommit)
			writeCommit="true"
			break
		;;
		--pageVisit)
			pageVisit="true"
			break
		;;
		--recentCommit)
			recentCommit="true"
			break
		;;
		-ssl)
			echo "ssl set"
			ssl="true"
			selfSign="true"
		;;
		-ca)
			selfSign="false"

	esac
done

./parseJSON.sh "$(curl -s -X POST --cacert /etc/shell/keys/jeremy-clifton.crt https://jeremy-clifton.com/history/writeCommit/)" name
serverProtocol=$(./urlParser.sh $serverName | awk '{ print $1 }')
serverFQDN=$(./urlParser.sh $serverName | awk '{ print $2 }')
serverPath=$(./urlParser.sh $serverName | awk '{ print $3 }')
certFlag=""
if [ $serverProtocol == 'https' ];
then
	keyRing --list | grep $serverFQDN
	if [ $? -eq 0 ]; 
	then
		echo "Key in key ring."
	else
		keyRing --add $serverFQDN
	fi
	certFlag=" --cacert /etc/shell/keys/$(echo $serverFQDN | sed 's/\..*$//g')"
if [ $serverProtocol == 'http' ];
then
	certFlag=""
else
	keyRing --list | grep $serverFQDN
	if [ $? -eq 0 ]; 
	then
		echo "Key in key ring."
	else
		keyRing --add $serverFQDN
	fi
	certFlag=" --cacert /etc/shell/keys/$(echo $serverFQDN | sed 's/\..*$//g')"
fi
responseCode=$(curl  -i $certFlag $serverName | grep HTTP | awk '{ print  $2 }')
#curl  -i --cacert /etc/shell/keys/jeremy-clifton.crt $serverName 
if [ $responseCode -ne 200 ]; then
	echo "Server error. Exiting."
	exit
else	
	echo "Server Response 200"
fi

if [ $writeCommit == "true" ]; 
then
fi

if [ $pageVisit == "true" ]; 
then
fi

if [ $recentCommit == "true" ]; 
then
fi

#if [ $writeCommit == "true" ]; 
#then
#fi


