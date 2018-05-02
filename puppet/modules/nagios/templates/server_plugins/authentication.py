#!/usr/local/python27/bin/python

import urllib2
import json
import hashlib
import sys

from random import randrange


class WebsiteTasks:

	def __init__(self):
		serviceRequest = {"Email" : "service.monitor@eh.com","Password" : "111111","ProductId" : 100}
		headers = {'content-type':'application/json'}
		jsonstr = json.dumps(serviceRequest)

		req = urllib2.Request('http://secure.agoramedia.com/AuthenticationService/Auth.svc/AccountLogin',data=jsonstr,headers=headers)

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
			print("LOGIN FAILED:" + response.read())
			
		if tokenResponse['ResponseStatus'] != 1:
			print("CRITICAL: SERVICE ERROR: " + response.read())
			sys.exit(2)
		else:
			print("OK: AccountProviderType => WFM = " + tokenResponse['AccountProviderType']) #+ tokenResponse['CommandResponse']['session_id'])
			sys.exit(0)


WebsiteTasks()
