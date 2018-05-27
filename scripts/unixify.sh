asdf1=$(md5sum https | cut -c 1-32)
asdf2=$(md5sum https | cut -c 1-32)
if [ $asdf1 == $asdf2]; then
	echo "no..."
else
	echo "..."
	for file in "find $1";do
		echo "file $file"
	done
	echo "Directory: $1"

fi
asdf='4'
fdsa='wa'
echo $asdf.$fdsa

