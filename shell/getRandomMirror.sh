fileSize=$(wc -l /etc/shell/mirrors | sed "s/\s.*//")
randLine=$(($RANDOM % $fileSize))
randServer=$(sed "${randLine}q;d" /etc/shell/mirrors)
url=$(sed "s/^#Server = //" <<< ${randServer})
echo $url
