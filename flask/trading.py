import json, hmac, hashlib, time, requests
from requests.auth import AuthBase


uri="https://*.com"
class tradingAuth(AuthBase, uri):
	def __init__(self, api_key, secret_key):
		self.api_key = api_key
		self.secret_key = secret_key
		self.uri = uri
	def __call__(self, request):
		timestamp = str(int(time.time()))
		message = timestamp + request.method + request.path_url+ (request.body or '')
		signature = hmac.new(self.secret_key, message, hashlib.sha256).hexdigest()

	request.headers.update({
		'CB-ACCESS-SIGN': signature,
		'CB-ACCESS-TIMESTAMP': timestamp,
		'CB-ACCESS-KEY': self.api_key
	})
	return request



class trading
