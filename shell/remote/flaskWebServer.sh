SAVED_DIRECTORY=$(pwd)
curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
python get-pip.py
rm get-pip.py
pip install Flask
cd /opt/flask
FLASK_APP=historyDocumentation.py
flask run&
cat /etc/crontab | grep checkFlask
if [ $? -ne '0' ];
then
echo "* /5 * * * * checkFlask" >> /etc/crontab
fi

cd $SAVED_DIRECTORY
