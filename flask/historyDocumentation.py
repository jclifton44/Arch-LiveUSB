from flask import Flask, url_for, request
import logging, pymongo, datetime, json, re
from pymongo import MongoClient
uri="https://jeremy-clifton.com/"
app = Flask(__name__)

@app.route("/history/")
def hello():
	return "<h1>Page History Versioning Utility</h1><br><a href='"+uri+"history/writeCommit/'> Commits </a>"


@app.route("/history/pageVisit/<commit>/",methods=['GET','POST'])
def pageVisit(commit):
	print('Connecting to client')
	client=MongoClient()
	db=client.historyDocumentation
	visitedSites=db.visitedSites	
	commits=db.commits
	formData=request.form
	#print formData['site']
	responsePage="<h1>"+commit+": </h1><br><a href='"+uri+"history/writeCommit/'> Back to commits</a> <br>Sites: <br>"
	if request.method == "GET":
		valid=re.compile(r"^\w*$")
		if valid.match(commit) is None:
			return "invalid request"
		pageVisitsDuringCommit=visitedSites.find({"commit":commit}).sort('date',pymongo.DESCENDING)
		for pageVisit in pageVisitsDuringCommit:
			responsePage+=pageVisit['site']+"<br>"
		
	if request.method == "POST":	
		if formData.has_key('site'):
			valid=re.compile(r"^\w*$")
                	if valid.match(commit) is None:
                        	return "invalid request"
			valid=re.compile(r"^[A-Za-z0-9-\.\_\~\:\/\?\#\[\]\@\!\$\&\'\(\)\*\+\,\;\=]*$")
			if valid.match(formData['site']) is None:
				return "invalid request"
			if commits.count_documents({"name":commit}) == 0:
				c={ "date": datetime.datetime.utcnow(),
					"name":commit}
				c_id=commits.insert_one(c).inserted_id
			
			siteVisit={"date": datetime.datetime.utcnow(),
				"site":	formData['site'],
				"commit": commit,
				}
			visitedSite_id=visitedSites.insert_one(siteVisit).inserted_id
		else:
			visitedSitesDuringCommit=visitedSites.find({"commit":commit}).sort('date',pymongo.DESCENDING)
			jsonSiteObject={}
			jsonSiteObject['commit'] = commit
			jsonSiteObject['sites'] = []
			for siteVisit in visitedSitesDuringCommit:
				jsonSiteObject['sites'].append(siteVisit['site'])
			return json.dumps(jsonSiteObject)
			
			 
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
		allCommits=commits.find().sort('date',pymongo.DESCENDING)
		for c in allCommits:
			responsePage+="<a href='"+uri+"history/pageVisit/"+c['name']+"/'>"+c['name']+"</a><br>"
	if request.method == "POST":	
		if formData.has_key('commit'):
			valid=re.compile(r"^\w*$")
			if valid.match(formData['commit']) is None:
				return "invalid request"
			c = { "date": datetime.datetime.utcnow(),
			"name":formData['commit']
			}
			c_id=commits.insert_one(c).inserted_id
		else:
			allCommits=commits.find().sort('date',pymongo.DESCENDING)
			jsonCommitObject={}
			mostRecentCommit=allCommits[1]['name'] if allCommits[0]['name'] == 'error' else allCommits[0]['name']
			jsonCommitObject['name']=mostRecentCommit
			return json.dumps(jsonCommitObject)
			
		
	return responsePage




