#!/usr/bin/python

import simplejson as json
import hashlib
import urllib2
import sys
import time

from random import randrange

class WebsiteTasks:
    
    def __init__(self):
        self.token = ''
        self.validationKey = ''
        self.userId = "locust_swarm_2_"  + str(randrange(9000000))

    def getToken(self):
		req = urllib2.Request('http://services.everydayhealth.com/ExternalServicesGateway/TokenGatewayServices.svc/GetToken')

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

		tokenResponse = json.loads(response.read())

		if tokenResponse == "":
			print "FAILURE: No Token"
			sys.exit(2)

		#print(tokenResponse)
		self.token = tokenResponse["Token"]
		#print(self.token)
		#print("Response token:" + self.token)
		self.validationKey = hashlib.md5((self.token + "hk@#3as82s5$@Q#$asdeq14$#89#$#Sfhgrvgw#t=2").encode('utf-8')).hexdigest()
		#print("md5: " + self.validationKey)

    def getSynchGatewaySession(self):
		self.getToken()
		serviceRequest = {
			'Token':self.token,
			'TokenValidationKey':self.validationKey,
			'VendorID':"EHMobile",
			'Command': {}
		}
		headers = {'content-type':'application/json'}
		jsonstr = json.dumps(serviceRequest)
		jsonstr = jsonstr.replace('{}', "{\"__type\":\"SyncGatewayGetSessionIdCommand:#WFM.Services.ExternalServicesGateway.Contract.Commands\",\"Database\":\"mcd_sync_gateway\",\"UserType\":\"mcduser\", \"UserId\":\"" + self.userId + "\"}")
		#print(jsonstr)
		req = urllib2.Request("http://services.everydayhealth.com/ExternalServicesGateway/TokenGatewayServices.svc/ExecuteCommand", data=jsonstr, headers=headers)
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
			print("CRITICAL: SYSTEM ERROR: " + json.dumps(serviceResponse))
			sys.exit(2)
		else:
			print("OK: session_id: " + serviceResponse['CommandResponse']['session_id'])
			sys.exit(0)


NotCheng = WebsiteTasks()
time.sleep(2)
NotCheng.getSynchGatewaySession()

