#!/usr/bin/python

import simplejson as json
import hashlib
import urllib2
import sys

from random import randrange

class WebsiteTasks:
	
	def __init__(self):
		self.token = ''
		self.validationKey = ''
		self.userId = "locust_swarm_2_"  + str(randrange(9000000))

	def getToken(self):
		req = urllib2.Request("http://services.everydayhealth.com/RegistrationService/Registration.svc/Registration/GetToken")

		try:
			response = urllib2.urlopen(req, data='')
		except urllib2.HTTPError, e:
			print('CRITICAL: getToken HTTPError = ' + str(e.code))
			sys.exit(2)
		except urllib2.URLError, e:
			print('CRITICAL: getToken URLError = ' + str(e.reason))
			sys.exit(2)
		except Exception:
			import traceback
			print('CRITICAL: getToken generic exception: ' + traceback.format_exc())
			sys.exit(2)

		tokenResponse = json.loads(response.read())

		if tokenResponse == "":
			print "FAILURE: No Token"
			sys.exit(2)

		#print(tokenResponse)
		self.token = tokenResponse["Message"]
		#print(self.token)
		#print("Response token:" + self.token)
		self.validationKey = hashlib.md5((self.token + "d963e223glsd$398#u792)99jOAiCKYn2xny3O+j0=").encode('utf-8')).hexdigest()
		#print("md5: " + self.validationKey)

	def getRegisterUser(self):

		self.screenName = 'locus_user' + str(randrange(9000000))
		self.email = self.screenName + '.' + str(randrange(9000000)) + '@mailinator.com'
		
		self.getToken()
		
		serviceRequest = {
"VendorName": "JillianMichaels",
"PromoCode": "C9098BB3-4E02-4A34-A710-F46EA2EF2232",
"ProductId": 58,
"VendorKey": "aRPSzfOEtn/x8Ys48lsfsilTrUminwxwi89YsBxD58w=",
"RequestHost": "JM 6.0.0",
"AccountProviderProperties": [{
	"Key": "ValidateReceipt",
	"Value": "false"
}],
"AwardKey": "Nagios: Registration|Monitor",
"Token": self.token,
"User": {
	"EmailAddress": self.email,
	"Password": "111111",
	"ScreenName": self.screenName,
	"LastName": self.screenName,
	"FirstName": self.screenName
},
"AccountProviderType": "Apple",
"ValidationKey": self.validationKey
}
		
		#print(self.token)
		headers = {'content-type':'application/json'}
		jsonstr = json.dumps(serviceRequest)
		#print("jsonstr" + jsonstr)

		req = urllib2.Request("http://services.everydayhealth.com/RegistrationService/Registration.svc/Registration/Register", data=jsonstr, headers=headers)
		try:
			response = urllib2.urlopen(req)
		except urllib2.HTTPError, e:
			print('CRITICAL: HTTPError = ' + str(e.code))
			sys.exit(2)
		except urllib2.URLError, e:
			print('CRITICAL: URLError = ' + str(e.reason))
			sys.exit(2)
		except Exception:
			import traceback
			print('CRITICAL: generic exception: ' + traceback.format_exc())
			sys.exit(2)

		serviceResponse = json.loads(response.read())
		
		if serviceResponse['ResponseStatus'] != 1:
			print("CRITICAL: SERVICE ERROR: " + response.read())
			sys.exit(2)
		else:
			print("OK: Response UserId:" + str(serviceResponse['UserId']))
			sys.exit(0)

NotCheng = WebsiteTasks()
NotCheng.getRegisterUser()
