#!/usr/local/python27/bin/python

import ssl
import urllib2
import json
import hashlib
import sys

from random import randrange


class WebsiteTasks:

	def __init__(self):
		serviceRequest = {
			"HealthProfile": {
				"InsuranceCompanyId": "cd5348be-1835-42f0-8915-f45e88a372d9",
				"FirstName": "TEST",
				"LastName": "TEST",
				"Gender": "F",
				"Email": "TEST@TEST.com",
				"Zip" : 31231,
				"ApplicationSource": "WTE-Android",
				"ProductId": "100",
				"IsFirstTimeParent": 'true',
				"DueDate": "2016-01-10"
			}
		}
		headers = {'content-type':'application/json', 'validate-token':'false'}
		jsonstr = json.dumps(serviceRequest)

		req = urllib2.Request('https://healthdataservices.everydayhealth.com/UserHealthProfileService/api/v1/userhealthprofile/',data=jsonstr,headers=headers)

		gcontent = ssl.SSLContext(ssl.CERT_REQUIRED)

		try:
			response = urllib2.urlopen(req, context=gcontent)
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
			print("LOGIN FAILED:" + response.read())
			
		if tokenResponse['ResponseStatus'] != 1:
			print("CRITICAL: SERVICE ERROR: " + response.read())
			sys.exit(2)
		else:
			print ("OK - ResponseStatus: 1");
			sys.exit(0)


WebsiteTasks()
