ovpn="false"
flask="false"
postfix="false"
ssl="false"
keyName="jeremy-clifton"
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
apt-get update
apt-get install nginx git
ufw allow 'OpenSSH'
ufw allow 'Nginx HTTP'
cp /etc/shell/nginx.conf /etc/nginx/sites-enabled/default
if [[ $ssl == 'true' ]];
then
	sed -i "s/#listen 443 ssl default_server;/listen 443 ssl default_server;/g" /etc/nginx/sites-enabled/default
 	sed -i "s/#listen [::]:443 ssl default_server;/listen [::]:443 ssl default_server;/g" /etc/nginx/sites-enabled/default
	sed -i "s/#include snippets/ssl-params.conf;/include snippets/ssl-params.conf;/g" /etc/nginx/sites-enabled/default
	ufw allow 'Nginx HTTPS'
	cp /etc/shell/nginxSSL.conf /etc/nginx/snippets/ssl-params.conf
	openssl dhparam -out /etc/ssl/dhparam.pem 2048
	key-csr-cert $keyName -s
	cp $keyName.key /etc/ssl/private/$keyName.key
	cp $keyName.crt /etc/ssl/certs/$keyName.crt
	rm $keyName.key
	rm $keyName.crt
	if [ $selfSign == 'false' ];
	then
		key-csr-cert $keyName
		cp $keyName.key $HOME/$keyName.key
		cp $keyName.csr $HOME/$keyName.csr
		cp /etc/shell/CSRMessage $HOME/CSRMessage
	fi
fi
ufw allow ssh
ufw app list
ufw enable
ufw status verbose
systemctl restart nginx
compressInstall
mkdir /var/www/html/hosted
cp compressed-shell-scripts-source.tar.gz /var/www/html/hosted/
rm compressed-shell-scripts-source.tar.gz
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
