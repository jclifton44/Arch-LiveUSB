serverName=$1
writeCommit="false"
pageVisit="false"
recentCommit="false"
commitName=""
debug="nodebug"
shift
for i in "$@"
do	
	case $1 in
		--writeCommit)
			writeCommit="true"
			newCommitName=$2
			break
		;;
		--pageVisit)
			pageVisit="true"
			commitName="$2"
			break
		;;
		--recentCommit)
			recentCommit="true"
			break
		;;
		-ssl)
			ssl="true"
			selfSign="true"
		;;
		-ca)
			selfSign="false"

	esac
done
if [ "$newCommitName" == "" ]; then
	newCommitName=$(openssl rand -hex 4)
fi
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
	certFlag=" --cacert /etc/shell/keys/$(echo $serverFQDN | sed 's/\..*$//g').crt"
elif [ $serverProtocol == 'http' ];
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
	certFlag=" --cacert /etc/shell/keys/$(echo $serverFQDN | sed 's/\..*$//g').crt"
fi
#curl  -i --cacert /etc/shell/keys/jeremy-clifton.crt $serverName 
echo "checking connectivity"
if [ "$debug" == "debug" ];
then
	echo "debug mode"
	curl -s -i -m 15 $certFlag $serverName 
fi
responseCode=$(curl -s -i -m 15 $certFlag $serverName | grep HTTP | awk '{ print  $2 }')
if [ "$responseCode" != "200" ]; then
	echo "Server error. Exiting."	
	echo "Response: $responseCode"
	exit
else	
	echo "Server Response 200"
fi

if [ $writeCommit == "true" ]; 
then
	echo "writeCommit"
	curl -s -X POST -d "commit=$newCommitName" $certFlag http://jeremy-clifton.com/history/writeCommit/
fi

if [ $pageVisit == "true" ]; 
then
	latestLocation=$(./parseJSON.sh "$(curl -s -X POST $certFlag https://jeremy-clifton.com/history/writeCommit/)" name)
	siteArray=$(./parseJSON.sh "$(curl -s -X POST $certFlag https://jeremy-clifton.com/history/pageVisit/$latestLocation/)" sites)
	count=0	
	./parseJSON.sh "$siteArray" 0
	while [ $? -eq 0 ]; 
	do
		echo $(./parseJSON.sh "$siteArray" $count)
		count=$((count+1))
		./parseJSON.sh "$siteArray" $count >> /dev/null
	done

fi

if [ $recentCommit == "true" ]; 
then
	echo "commit: "$(./parseJSON.sh "$(curl -s -X POST $certFlag https://jeremy-clifton.com/history/writeCommit/)" name)
fi
