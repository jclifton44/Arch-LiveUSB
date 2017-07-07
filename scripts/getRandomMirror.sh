cat /mnt/sslMirrorList | grep "Server = https" > getRandomMirrors
sed "s/#Server/Server/" getRandomMirrors > getRandomMirrorsList
fileLength=$(wc -l mirrors | awk '{print $1}')
randomLength=$(($RANDOM % $fileLength))
#echo "randomLength: $randomLength"
randomMirror=$(sed "${randomLength}q;d" getRandomMirrorsList | awk '{print $3}')
echo $randomMirror
