from flask import Flask, url_for, request
import logging

app = Flask(__name__)

@app.route("/history/")
def hello():
	return "Page History Versioning Utility"


@app.route("/history/pageVisit/<commit>",methods=['GET','POST'])
def pageVisit(commit):
	app.logger.info("IFNO MESSAGE:");
	if request.method == "GET":
		return request.data
	if request.method == "POST":	
		return request.data	
	return  "good"

@app.route("/history/writeCommit/<commit>",methods=['GET','POST'])
def writeCommit(commit):
	if request.method == "GET":
		return "good"
	if request.method == "POST":	
		return "good"
	return "good"




