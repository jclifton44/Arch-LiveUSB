for line in $(ls); do rm /usr/bin/$(echo $line | sed -s 's/\.sh//g') ; done

