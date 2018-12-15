ovpn="false"
flask="false"
postfix="false"
for i in "$@"
do	
	case $i in
		-o*)
			echo "-o set"
			ovpn="true"
			shift
		;;
		-f*)
			echo "-f set"
			flask="true"
			shift
		;;
		-p)
			echo "-p set"
			postfix="true"
	esac
done
apt-get update
apt-get install nginx git
ufw allow 'Nginx HTTP'
ufw allow 'OpenSHH'
ufw allow ssh
ufw app list
ufw enable
ufw status verbose
cp /etc/shell/nginx.conf /etc/nginx/sites-enabled/default
systemctl restart nginx
compressInstall
mkdir /var/www/html/hosted
cp compressed-shell-scripts-source.tar.gz /var/www/html/hosted/
if [[ $ovpn == 'true' ]]; 
then	
	setupOVPN 
fi
if [[ $flask == 'true' ]];
then
	echo "Starting Flask webserver"
	sleep 2
	deployStack
fi
if [[ $postfix == 'true' ]];
then
	echo "Setting up email postfix server"
	sleep 2
	setupPostfix
fi

