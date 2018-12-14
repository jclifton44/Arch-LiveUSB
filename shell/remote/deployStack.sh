mongoDBVersion="4.0.4"
SAVED_DIRECTORY=$(pwd)
releaseName=$(lsb_release  -c | awk '{ print $2 }')
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
python get-pip.py
rm get-pip.py
wget https://repo.mongodb.org/apt/ubuntu/dists/$releaseName/mongodb-org/4.0/multiverse/binary-amd64/mongodb-org-server_${mongoDBVersion}_amd64.deb
dpkg -i mongodb-org-server_${mongoDBVersion}_amd64.deb
pip install pymongo
mkdir -p /data/db
#pip install Jinja2
pip install Flask 
cd /opt/flask
export FLASK_APP=historyDocumentation.py
flask run&
cat /etc/crontab | grep checkFlask
if [ $? -ne '0' ];
then
echo "* /5 * * * * checkFlask" >> /etc/crontab
fi

cd $SAVED_DIRECTORY
