SAVED_DIRECTORY=$(pwd)
cd /opt/flask
FLASK_APP=historyDocumentation.py
flask run&
cat /etc/crontab | grep checkFlask
if [ $? -ne '0' ];
then
echo "* /5 * * * * checkFlask" >> /etc/crontab
fi

cd $SAVED_DIRECTORY
