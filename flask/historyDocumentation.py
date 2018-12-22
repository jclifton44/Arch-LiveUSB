from flask import Flask, url_for, request
import logging, pymongo, datetime, json
from pymongo import MongoClient

app = Flask(__name__)

@app.route("/history/")
def hello():
	return "Page History Versioning Utility"


@app.route("/history/pageVisit/<commit>/",methods=['GET','POST'])
def pageVisit(commit):
	print('Connecting to client')
	client=MongoClient()
	db=client.historyDocumentation
	visitedSites=db.visitedSites	
	formData=request.form
	#print formData['site']
	responsePage="<h1>"+commit+": </h1> <br>Sites: <br>"
	if request.method == "GET":
		print "GET MESSAGE"
		pageVisitsDuringCommit=visitedSites.find({"commit":commit})	
		for pageVisit in pageVisitsDuringCommit:
			responsePage+=pageVisit['site']+"<br>"
		
	if request.method == "POST":	
		siteVisit={"date": datetime.datetime.utcnow(),
			"site":	formData['site'],
			"commit": commit,
			}
		visitedSite_id=visitedSites.insert_one(siteVisit).inserted_id
		#print "Inserted document id: " + visitedSite_id
		
	
	client.close()
	return  responsePage

@app.route("/history/writeCommit/<commit>",methods=['GET','POST'])
def writeCommit(commit):
	if request.method == "GET":
		return "good"
	if request.method == "POST":	
		return "good"
	return "good"




