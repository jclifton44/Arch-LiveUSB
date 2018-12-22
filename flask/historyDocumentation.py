from flask import Flask, url_for, request
import logging, pymongo, datetime, json
from pymongo import MongoClient
uri="https://jeremy-clifton.com/"
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
	commits=db.commits
	formData=request.form
	#print formData['site']
	responsePage="<h1>"+commit+": </h1> <br>Sites: <br>"
	if request.method == "GET":
		print "GET MESSAGE"
		pageVisitsDuringCommit=visitedSites.find({"commit":commit})	
		for pageVisit in pageVisitsDuringCommit:
			responsePage+=pageVisit['site']+"<br>"
		
	if request.method == "POST":	
		if commits.count_documents({"name":commit}) == 0:
			commitForSite=commits.find({"name":commit})
			c={ "date": datetime.datetime.utcnow(),
				"name":commit}
			c_id=commits.insert_one(c).inserted_id
		
		siteVisit={"date": datetime.datetime.utcnow(),
			"site":	formData['site'],
			"commit": commit,
			}
		visitedSite_id=visitedSites.insert_one(siteVisit).inserted_id
		#print "Inserted document id: " + visitedSite_id
		
	
	client.close()
	return  responsePage

@app.route("/history/writeCommit/",methods=['GET','POST'])
def writeCommit():
	print('Connecting to client for writeCommit')
	client=MongoClient()
	db=client.historyDocumentation
	commits=db.commits 
	formData=request.form
	responsePage="<h1>Commits:</h1><br>"	
	if request.method == "GET":
		allCommits=commits.find()
		for c in allCommits:
			responsePage+="<a href='"+uri+"history/pageVisit/"+c['name']+"/'>"+c['name']+"</a><br>"
	if request.method == "POST":	
		c = { "date": datetime.datetime.utcnow(),
		"name":formData['commit']
		}
		c_id=commits.insert_one(c).inserted_id
	return responsePage




