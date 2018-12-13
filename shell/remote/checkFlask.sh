ps ax | grep "flask run" | grep bin
if [ $? -ne '0' ];
then
	cd /opt/flask
	export FLASK_APP=historyDocumentation.py
	flask run&
fi

