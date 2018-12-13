from flask import Flask
app = Flask(__name__)

@app.route('/history/')
def hello():
	return "Hello World"
