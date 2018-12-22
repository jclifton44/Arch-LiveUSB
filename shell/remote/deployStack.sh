mongoDBKey="https://www.mongodb.org/static/pgp/server-4.0.asc"
SAVED_DIRECTORY=$(pwd)
releaseName=$(lsb_release  -c | awk '{ print $2 }')
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
python get-pip.py
rm get-pip.py
curl $mongoDBKey | apt-key add
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list
apt-get update
#dpkg -i mongodb-org-server_${mongoDBVersion}_amd64.deb
apt-get install mongodb-org
pip install pymongo
mongo 127.0.0.1:27017/historyDocumentation  < /etc/shell/setup.historyDocumentation
mkdir -p /data/db
#pip install Jinja2
pip install Flask 
cd /opt/flask
export FLASK_APP=historyDocumentation.py
flask run&
cat /etc/crontab | grep checkServices
if [ $? -ne '0' ];
then
echo "* /5 * * * * checkServices" >> /etc/crontab
fi

cd $SAVED_DIRECTORY
