#!/usr/local/python27/bin/python

import json
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

		self.token = tokenResponse["Token"]
		self.validationKey = hashlib.md5((self.token + "hk@#3as82s5$@Q#$asdeq14$#89#$#Sfhgrvgw#t=2").encode('utf-8')).hexdigest()

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
		jsonstr = jsonstr.replace('{}', '{"__type":"LeadGenServiceCommand:#WFM.Services.ExternalServicesGateway.Contract.Commands","LeadGenService":{"RequestType":0,"LeadGenParameters":[{"Key":"email","Value":"service.monitor@eh.com"}, {"Key":"zip","Value":"10014"}, {"Key":"babyduedate","Value":"02012016"}, {"Key":"FirstTimeParent","Value":"True"}, {"Key":"isMom","Value":"True"}, {"Key":"source","Value":"mobile-wtept"}],"OfferName":"WTEleadgen"}}')
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
			print("CRITICAL: SERVICE ERROR: " + response.read())
			sys.exit(2)
		else:
			print("OK: ResponseStatus: " + str(serviceResponse['ResponseStatus']))
			sys.exit(0)


NotCheng = WebsiteTasks()
NotCheng.getSynchGatewaySession()


