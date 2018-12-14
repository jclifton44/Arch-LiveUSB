SAVED_DIRECTORY=$(pwd)
apt-get install make
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
python get-pip.py
rm get-pip.py
pip install Flask
wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cp -r redis-stable /opt/
cd /opt/redis-stable/
make
#pip install Jinja2
cd /opt/flask
export FLASK_APP=historyDocumentation.py
flask run&
cat /etc/crontab | grep checkFlask
if [ $? -ne '0' ];
then
echo "* /5 * * * * checkFlask" >> /etc/crontab
fi

cd $SAVED_DIRECTORY
