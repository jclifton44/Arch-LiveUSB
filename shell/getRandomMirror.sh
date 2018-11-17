fileSize=$(wc -l ../mirrors | sed "s/\s.*//")
randLine=$(($RANDOM % $fileSize))
randServer=$(sed "${randLine}q;d" ../mirrors)
url=$(sed "s/^#Server = //" <<< ${randServer})
echo $url
