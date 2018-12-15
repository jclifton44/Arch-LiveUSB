apt-get install postfix
#
echo "postfix postfix/destinations string \$myhostname, jeremy-clifton.com, mail.jeremy-clifton.com, localhost.jeremy-clifton.com, localhost" | debconf-set-selections
echo "postfix postfix/mailbox_limit string 0" | debconf-set-selections
echo "postfix postfix/mailname string jeremy-clifton.com" | debconf-set-selections
echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections
echo "postfix postfix/protocols select ipv4" | debconf-set-selections
echo "postfix postfix/root_address string root" | debconf-set-selections
rm /etc/postfix/main.cf	
dpkg-reconfigure -f noninteractive postfix
postconf -e 'home_mailbox= Maildir/'
postconf -e 'virtual_alias_maps= hash:/etc/postfix/virtual'

#force syncronous updates on mail queue: no
#general type of mail configuration: InternetSite
#dpkg-reconfigure postfix

echo "root@jeremy-clifton.com root" >> /etc/postfix/virtual
ufw allow Postfix
export MAIL=$HOME/Maildir
echo "export MAIL=$HOME/Maildir" | tee -a /etc/bash.bashrc

postmap /etc/postfix/virtual
systemctl restart postfix
apt-get install s-nail
echo "set emptystart" >> /etc/s-nail.rc
echo "set folder=Maildir" >> /etc/s-nail.rc
echo "set recort=+sent" >> /etc/s-nail.rc

echo 'init' | mail -s 'init' -Snorecord root
#WAY TO CREATE MAILDIR  (complicated or clever?)
#https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-on-ubuntu-16-04 
