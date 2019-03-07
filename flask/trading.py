import json, hmac, hashlib, time, requests, base64 
from requests.auth import AuthBase

import pymongo
from pymongo import MongoClient


uri="https://*.com"
class tradingAuth(AuthBase):
	passphrase="nopassphrase"
	def __init__(self, api_key, secret_key, passphrase):
		self.api_key = api_key
		self.secret_key = secret_key
		self.passphrase = passphrase
	def __call__(self, request):
		timestamp = str(time.time())
		message = timestamp + request.method + request.path_url+ (request.body or '')
		hmac_key = base64.b64decode(self.secret_key)
		
		signature = hmac.new(hmac_key, message, hashlib.sha256)
		signature_b64 = signature.digest().encode('base64').rstrip('\n')

		request.headers.update({
			'CB-ACCESS-SIGN': signature_b64,
			'CB-ACCESS-TIMESTAMP': timestamp,
			'CB-ACCESS-KEY': self.api_key,
			'CB-ACCESS-PASSPHRASE': self.passphrase
		})
		return request


class tradingClass():
	API_Secret = ""
	API_Key = ""
	passphrase = ""
	auth = {}
	def __init__(self, api_key, secret_key, passphrase):
		print("init")
		self.API_Secret = secret_key
		self.API_Key = api_key
		self.passphrase = passphrase
		self.auth = tradingAuth(self.API_Key, self.API_Secret, self.passphrase)
		#gather data
		#connect to mongodb
		#generate signal
	def getPrices(self):			
		
		client=MongoClient()
		db=client.trading
		prices=db.prices
		p = prices.find({})
		priceArray = []
		for entry in p:
			priceArray.append(entry)
		
			
		return priceArray
		

	
	def updatePrice(self):
		r = requests.get('https://api.pro.coinbase.com/products/BTC-USD/ticker', auth=self.auth)
	
		print 'Price Update...'
		print r.json()
		client=MongoClient()
		db=client.trading
		prices=db.prices
		responsePrice = r.json()
		responsePrice['time'] = time.time()
		pricesKeepLimit = 60 * 300 * 1000 # five minutes X 1000
		pricesKeepThreshold = time.time() - pricesKeepLimit
		prices.delete_many( { "time": { "$lt": pricesKeepThreshold } } )
		prices.insert_one(responsePrice)

		

