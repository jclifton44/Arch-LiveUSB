fileSize=$(wc -l /mnt/mirrors | sed "s/\s.*//")
randLine=$((RANDOM % $fileSize))
randServer=$(sed "${randLine}q;d" /mnt/mirrors)
url=$(sed "s/^#Server = //" <<< ${randServer})
echo $url
