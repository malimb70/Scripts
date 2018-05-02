#!/usr/local/python27/bin/python
import json
#import simplejson as json
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
        req = urllib2.Request('http://services.everydayhealth.com/UserService/SecurityTokenService.svc/GetToken')

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
        self.validationKey = hashlib.md5((self.token + "d963e223glsd$398#u792)99jOAiCKYn2xny3O+j0=").encode('utf-8')).hexdigest()
        #print("md5: " + self.validationKey)

    def userSync(self):
        self.getToken()
        serviceRequest = {
            'ApplicationName':"WTE",
            'TokenValidationKey':self.validationKey,
            'Token':self.token,
            'UserId':67075862,
            'ProductId':100,
            'ApplicationSource':"Mobile: Android",
            'User':{'Gender':'F','ScreenName':'servicemonitor','ZipCode':'10014'},
            'Children':[]
        }

        headers = {'content-type':'application/json'}
        jsonstr = json.dumps(serviceRequest)
        #print(jsonstr)
        req = urllib2.Request("http://services.everydayhealth.com//UserService/UserSyncService.svc/v1/SyncUserSettings", data=jsonstr, headers=headers)
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
        #print response
        #print serviceResponse
 
        if serviceResponse['ResponseStatus'] != 1:
            print("CRITICAL: SERVICE ERROR: " + response.read())
            sys.exit(2)
        else:
            print("OK: ResponseStatus: " + str(serviceResponse['ResponseStatus']))
            sys.exit(0)


NotCheng = WebsiteTasks()
NotCheng.userSync()


