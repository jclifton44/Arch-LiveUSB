from flask import Flask, url_for, request

import logging, pymongo, datetime, json, re, requests
from pymongo import MongoClient
from urlparse import urlparse
dictionaryAPIKey="7e906e34-8a6c-4680-8995-18b625688abd"
#key from dictionaryapi.com
uri="https://jeremy-clifton.com/"
app = Flask(__name__)

@app.route("/history/")
def hello():
	return "<h1>Page History Versioning Utility</h1><br><a href='"+uri+"history/writeCommit/'> Commits </a>"



@app.route("/history/definitions/",methods=['GET','POST'])
def definitions():
	client=MongoClient()
	db=client.historyDocumentation
	words=db.words
	if request.method == "GET":
		wordDefinitions=words.find().sort('date',pymongo.DESCENDING)
		wordTable="<table style=\"border:solid\">"
		for w in wordDefinitions:
			definitionElement=""
			for definition in w['definitions']:
				definitionElement+="- " + definition + "<br>"
			wordTable+="<tr><td style=\"vertical-align:top;\"  ><b>" + str(w['word']) + "</b></td><td> " + definitionElement + "</td></tr>"
		wordTable+="</table>"
		return wordTable
	return "Invalid Request"
	

@app.route("/history/pageVisit/<commit>/",methods=['GET','POST'])
def pageVisit(commit):
	print('Connecting to client')
	client=MongoClient()
	db=client.historyDocumentation
	visitedSites=db.visitedSites	
	commits=db.commits
	words=db.words
	formData=request.form
	print(formData)
	print "formData^"
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
			else:
				definitionUrl=urlparse(formData['site'])
				if formData.has_key('q'):
					definitionUrl.q = formData['q']
				else:
					definitionUrl.q = definitionUrl.query[2:]
				print "valid"
				print definitionUrl.path
				print definitionUrl.netloc
				print definitionUrl.q
				if definitionUrl.path == "/search" and definitionUrl.netloc == "www.google.com":
					print "search and google"
					definitionRegex=re.compile(r"^[A-Za-z]*$")
					print definitionUrl.query
					word=definitionUrl.q
					if definitionRegex.match(definitionUrl.q):
						definitionRequest=requests.get("https://dictionaryapi.com/api/v3/references/collegiate/json/" + word + "?key=" + dictionaryAPIKey)
						print "finding definition for " + word
						definition=json.loads(definitionRequest.content)
						if 'meta' in definition[0]:
							#print definition[0]['shortdef']
							w={ "word": word,
								"definitions":definition[0]['shortdef'],
								"date":datetime.datetime.utcnow()
							}
							w_id=words.insert_one(w).inserted_id
					else:
						print "deinition regex mismatch"	
							
				



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
	print(formData)
	responsePage="<h1>Commits:</h1><br>"	
	if request.method == "GET":
		allCommits=commits.find().sort('date',pymongo.DESCENDING)
		for c in allCommits:
			responsePage+="<a href='"+uri+"history/pageVisit/"+c['name']+"/'>"+c['name']+"</a><br>"
	if request.method == "POST":	
		print "POST"
		if formData.has_key('commit'):
			valid=re.compile(r"^\w*$")
			if valid.match(formData['commit']) is None:
				return "invalid request"
			c = { "date": datetime.datetime.utcnow(),
			"name":formData['commit']
			}
			
	
			c_id=commits.insert_one(c).inserted_id
		else:
			jsonCommitObject={}
			allCommits=commits.find().sort('date',pymongo.DESCENDING)
			mostRecentCommit=allCommits[1]['name'] if allCommits[0]['name'] == 'error' else allCommits[0]['name']
			jsonCommitObject['name']=mostRecentCommit
			return json.dumps(jsonCommitObject)
			
		
	return responsePage




