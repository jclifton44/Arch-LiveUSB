for line in $(ls); do cp $line /usr/bin/$(echo $line | sed -s 's/\.sh//g') ; done
cp -r ../conf/ /etc/conf
