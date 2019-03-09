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
	buyRules=[ [
			{	
				'o1':'priceDataPrimeAverage',
				'intervalOffset1': 0,
				'indexOffset1':0,
				'operation': '>',
				'o2':'zero',
				'intervalOffset2': 0,
				'indexOffset2':0,
				'label': 'l1'
			}, {
				'o1':'priceDataPrimeAverage',
				'intervalOffset1': 0,
				'indexOffset1':-1,
				'operation': '<',
				'o2':'zero',
				'intervalOffset2': 0,
				'indexOffset2':0,
				'label': 'l1'
			},
		]
	
	
	]
	
	sellRules=[ [
			{	
				'o1':'priceDataPrimeAverage',
				'intervalOffset1': 0,
				'indexOffset1':0,
				'operation': '<',
				'o2':'zero',
				'intervalOffset2': 0,
				'indexOffset2':0,
				'label': 'l1'
			}, {
				'o1':'priceDataPrimeAverage',
				'intervalOffset1': 0,
				'indexOffset1':-1,
				'operation': '>',
				'o2':'zero',
				'intervalOffset2': 0,
				'indexOffset2':0,
				'label': 'l1'
			},{
				'o1':'priceDataDoublePrimeAverage',
				'intervalOffset1': -5,
				'indexOffset1':0,
				'operation': '>',
				'o2':'zero',
				'intervalOffset2': 0,
				'indexOffset2':0,
				'label': 'l1'
			},
	
		]
	]
	def __init__(self, api_key, secret_key, passphrase):
		print("init")
		self.API_Secret = secret_key
		self.API_Key = api_key
		self.passphrase = passphrase
		self.auth = tradingAuth(self.API_Key, self.API_Secret, self.passphrase)
		datasets = {}
		prices = self.getPrices()
		datasets['intervalDatasets'] = {
			'priceDataPrimeAverage': {
				'range': list(range(1,20)),
				'datasetAttribute': 'priceDataPrime'
			},
			'priceDataDoublePrimeAverage': {
				'range': list(range(1,30)),
				'datasetAttribute': 'priceDataDoublePrime'
			}
		
		}				
		signalVariable = 'priceDataPrimeAverage'
		maxSignal = len(datasets['intervalDatasets'][signalVariable]['range'])										
		datasets = self.defineKeyDatasets(datasets)		
		datasets = self.generateDatasets(datasets, prices)
		signalInstance = self.genSignalOnIntervalDataset(self.buyRules, self.sellRules, signalVariable, datasets)


		#gather data
		#connect to mongodb
	def getGreaterBalance(self):
		#will obtain BTC balance and USD balance and return the one with greater value
		r = requests.get('https://api.pro.coinbase.com/accounts', auth=self.auth)
		accounts = r.json()
		balances = {}
		balances['USD'] = 0
		balances['BTC'] = 0
		for a in accounts:
			if a['currency'] == 'USD':
				balances['USD'] = a['balance']
			if a['currency'] == 'BTC':
				balances['BTC'] = a['balance']
				
		
		p = float(self.getPrice())
		if float(balances['USD']) * p < float(balances['BTC']):
			return 'BTC'
		else:
			return 'USD'
		
	def getUSD(self):
		#will obtain BTC balance and USD balance and return the one with greater value
		r = requests.get('https://api.pro.coinbase.com/accounts', auth=self.auth)
		accounts = r.json()
		balances = {}
		balances['USD'] = 0
		balances['BTC'] = 0
		for a in accounts:
			if a['currency'] == 'USD':
				balances['USD'] = a['balance']
			if a['currency'] == 'BTC':
				balances['BTC'] = a['balance']
				
		return float(balances['USD'])	
		
	def getBTC(self):
		#will obtain BTC balance and USD balance and return the one with greater value
		orderType={}
		orderType['status'] = 'all'	
		r = requests.get('https://api.pro.coinbase.com/accounts', json=orderType, auth=self.auth)
		
		accounts = r.json()
		balances = {}
		balances['USD'] = 0
		balances['BTC'] = 0
		for a in accounts:
			if a['currency'] == 'USD':
				balances['USD'] = a['balance']
			if a['currency'] == 'BTC':
				balances['BTC'] = a['balance']
				
		return float(balances['BTC'])	
	def getOrderBook(self):
		r = requests.get('https://api.pro.coinbase.com/products/BTC-USD/book?level=2', auth=self.auth)
		#print(str(r.json()))
		return r.json()
	
			

	def BTCtoUSD(self, isMakerTrade):

		client=MongoClient()
		db=client.trading
		submittedOrders=db.submittedOrders
		print("BTCtoUSD")
		order = {}
		order['side'] = 'sell'
		order['product_id'] = 'BTC-USD'
		p = -1
		orderBook = self.getOrderBook()
		#order of 2 is for testing
		for index in range(0,len(orderBook['asks']) - 1):
			difference = float(orderBook['asks'][index + 1][0]) - float(orderBook['asks'][index][0])
			if difference >= float(.02):
				p = ( float( orderBook['asks'][index][0] ) + float( orderBook['asks'][index + 1][0] ) ) / 2
				p = p / 2
				break
		if p == -1:
			return -1
	
		order['size'] = round(float( self.getBTC() - float( .00000001)), 8)

		
		order['cancel_after'] = 'hour'
		if not isMakerTrade:
			order['type'] = 'market'
		else:
			order['post_only'] = True
			order['price'] = round(p, 2)
		
		r = requests.post('https://api.pro.coinbase.com/orders', json=order, auth=self.auth)
		orderId = r.json()['id']
		print(str(r.json()))
		time.sleep(2)
		processedOrder
		for o in self.updateOrders():
			if o['id'] == order_id:
				processedOrder = o
				break
			
		if processedOrder['status'] == 'open':
			#order through
			orderDetails = {}
			orderDetails['time'] = time.time()
			orderDetails['remote'] = proessedOrder
			orderDetails['minutesTillCancel'] = 5
			submittedOrders.insert_one(orderDetails)
			
		else:
			print('order submitted not open... error.')
		return 0	










	
	def getOrders(self):
		orderType={}
		orderType['status'] = 'all'	

		r = requests.get('https://api.pro.coinbase.com/orders', json=orderType, auth=self.auth)
		return r.json()
	
	def getTimestampFromDate(self,date):
		#format: YYYY-MM-DDTHH:MM:SS.\d*Z
		print("conversion")
		
	def USDtoBTC(self, isMakerTrade):
		client=MongoClient()
		db=client.trading
		submittedOrders=db.submittedOrders
		print("USDtoBTC")
		order = {}
		order['side'] = 'buy'
		order['product_id'] = 'BTC-USD'
		p = self.getPrice()
		orderBook = self.getOrderBook()
		#order of 2 is for testing
		for index in range(0,len(orderBook['bids']) - 1):
			difference = float(orderBook['bids'][index][0]) - float(orderBook['bids'][index + 1][0])
			if difference >= float(.02):
				p = ( float( orderBook['bids'][index][0] ) + float( orderBook['bids'][index + 1][0] ) ) / 2
				p = p / 2
				break
	
		order['size'] = round(float( self.getUSD() / float( p * 2 ) ) - float( .00000001), 8)

		
		order['cancel_after'] = 'hour'
		if not isMakerTrade:
			order['type'] = 'market'
		else:
			order['post_only'] = True
			order['price'] = round(p, 2)
		
		r = requests.post('https://api.pro.coinbase.com/orders', json=order, auth=self.auth)
		orderId = r.json()['id']
		print(str(r.json()))
		time.sleep(2)
		processedOrder
		for o in self.updateOrders():
			if o['id'] == order_id:
				processedOrder = o
				break
			
		if processedOrder['status'] == 'open':
			#order through
			orderDetails = {}
			orderDetails['time'] = time.time()
			orderDetails['remote'] = proessedOrder
			orderDetails['minutesTillCancel'] = 5
			submittedOrders.insert_one(orderDetails)
			
		else:
			print('order submitted not open... error.')
			

		
	def checkRule(self, rules, datasets, interval, index):
		for ruleset in rules:

			ruleCheck = True
			for r in ruleset:
	
				indexOffset1 = r['indexOffset1']
				intervalOffset1 = r['intervalOffset1']
				operand1 = 0
				if interval + intervalOffset1 > 0 and index + indexOffset1 > 0 and r['o1'] != 'zero':
					operand1 = datasets[r['o1']][str(interval + intervalOffset1)][index + indexOffset1]
				elif r['o1'] == 'zero':
					operand1 = 0
				else:
					continue
				indexOffset2 = r['indexOffset2']
				intervalOffset2 = r['intervalOffset2']
	
	
				operand2 = 0
				if interval + intervalOffset2 > 0 and index + indexOffset2 > 0 and r['o2'] != 'zero':
					operand2 = datasets[r['o2']][str(interval + intervalOffset2)][index + indexOffset2]
				elif r['o2'] == 'zero':
					operand2 = 0
				else:
					continue
				#print(str(operand1) + " " + r['operation'] + " " +str(operand2))
				if r['operation'] == '>':
					if operand1 <= operand2:
						ruleCheck = False
				elif r['operation'] == '<':
					if operand1 >= operand2:
						ruleCheck = False
				elif r['operation'] == '==':
					ruleCheck |= operand1 == operand2
			if ruleCheck:
				return True
	
		return False
		
		
	

	def getPrices(self):			
		
		client=MongoClient()
		db=client.trading
		prices=db.prices
		p = prices.find({})
		priceArray = []
		for entry in p:
			priceArray.append(entry)
		
			
		return priceArray
		

	def getPrice(self):
		r = requests.get('https://api.pro.coinbase.com/products/BTC-USD/ticker', auth=self.auth)
		responsePrice = r.json()
		return responsePrice['price']


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

	def genSignal(self):
		datasets = {}
		
	def defineKeyDatasets(self, datasets):	
		datasetString=""
		for variableIntervalDataset in datasets['intervalDatasets'].keys():
			datasetString += variableIntervalDataset
			datasetString += str(datasets['intervalDatasets'][variableIntervalDataset]['range'])
			datasetString += str(datasets['intervalDatasets'][variableIntervalDataset]['datasetAttribute'])
			intervals = datasets['intervalDatasets'][variableIntervalDataset]['range']
			datasets[variableIntervalDataset] = {}
			for interval in intervals:
				datasets[variableIntervalDataset][str(interval)] = []
		datasets['initialID'] = hashlib.sha224(datasetString.encode('utf-8')).hexdigest()
		datasets['prices']=[]
		datasets['priceDataPrime']=[]
		datasets['priceDataDoublePrime']=[]
	
		return datasets



	def averageArray(self, array, interval, offset):
		sum=0
		for i in range(0,interval-1):
			if offset-i > 0 and offset-i < len(array):
				sum += array[offset-i]
		return sum/interval




	

	def generateDatasets(self, datasets, priceData):
	
		for index in range(0,len(priceData)):
			if index > 0:
				datasets['prices'].append(float(priceData[index]['price']))
				datasets['priceDataPrime'].append(float(priceData[index]['price'])-float(priceData[index-1]['price']))
	
		for index in range(0,len(datasets['priceDataPrime'])):
			if index > 0:
				datasets['priceDataDoublePrime'].append(datasets['priceDataPrime'][index]-datasets['priceDataPrime'][index-1])
	
		for index in range(0,len(priceData)):
			if index > 0:
				for intervalDataset in datasets['intervalDatasets'].keys():
					for interval in datasets['intervalDatasets'][intervalDataset]['range']:
						if len(datasets[datasets['intervalDatasets'][intervalDataset]['datasetAttribute']]) > int(interval):
							datasets[intervalDataset][str(interval)].append(self.averageArray(datasets[datasets['intervalDatasets'][intervalDataset]['datasetAttribute']],int(interval),index - 1))
	
	
		return datasets
					


	def genSignalOnIntervalDataset(self, buyRules, sellRules, variableNames, datasets):
		signalInstance=[0]*len(datasets['prices'])
		if isinstance(variableNames, list):
			variableName=variableName[0]
		else:
			variableName=variableNames
		datasetLength = len(datasets['prices'])
		for index in range(0,datasetLength):
			for interval in datasets[variableName].keys():
				
				signal=0
	
				if index < len(datasets['prices']) - int(interval):
	
					if self.checkRule(buyRules, datasets, int(interval), index):
						#if datasets['priceDataPrimeAverage'][interval][index] > 0 and datasets['priceDataPrimeAverage'][interval][index-1] < 0:
						signal+=1
						#print("signal  ------------: " + str(signal))
					elif self.checkRule(sellRules, datasets, int(interval), index):
						#elif datasets['priceDataPrimeAverage'][interval][index] < 0 and datasets['priceDataPrimeAverage'][interval][index-1] > 0:
						signal-=1
						#print("signal   IIIIIIIIIIIII: " + str(signal))
					
	
				if index + int(interval) < len(datasets['prices']):
					#print("assigningSignal")
					signalInstance[index+int(interval)]+=signal
		return signalInstance
	
	
		
