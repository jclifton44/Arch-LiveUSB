apt-get update
apt-get install nginx git
ufw allow 'Nginx HTTP'
ufw allow 'OpenSHH'
ufw allow ssh
ufw app list
ufw enable
ufw status verbose
cp /etc/shell/nginx.conf /etc/nginx/sites-available/default
systemctl restart nginx
compressInstall
cp compressed-shell-scripts-source.tar.gz /var/www/html/hosted/
