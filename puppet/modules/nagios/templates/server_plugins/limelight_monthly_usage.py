#!/usr/local/python27/bin/python

import urllib2,time,hmac,hashlib,logging
from datetime import datetime
from datetime import date
try: import simplejson as json
except ImportError: import json
LOG_FILENAME = "/var/log/traffic-reporting-api.log"
import sys

class ReportDuration:
    DAY = "DAY"
    WEEK = "WEEK"
    MONTH = "MONTH"
    CUSTOM = "CUSTOM"
    
class ServiceType:
    HTTP = "HTTP"
    HTTPS = "HTTPS"
    WINDOWS_MEDIA = "WINDOWSMEDIA"
    REDIRECTOR = "REDIRECTOR"
    QUICKTIME = "QUICKTIME"
    FLASH = "FLASH"
    SHOUTCAST = "SHOUTCAST"
    SHOUTCAST_NATIVE = "SHOUTCASTNATIVE"
    REALMEDIA = "REALMEDIA"
    DYNAMICORIGIN = "DYNAMICORIGIN"
    PARENTHTTP = "PARENTHTTP"
    DISK_USAGE = "DISKUSAGE"
    IPCONNECT ="IPCONNECT"
    STREAMMONITORING="STREAMMONITORING"
    HLS="HLS"
    HDS="HDS"
    
class TrafficReportType:
    SUMMARY="summary"
    USAGE="usage"
    STORAGE="storage"
    IPCONNECT="ipconnect"
    STREAMMONITORING="streammonitoring"
    TRAFFIC="traffic"

class TrafficReportingApi:
    def __init__(self,baseUrl,username,apiKey):
        self.baseUrl = baseUrl
        self.username = username 
        self.apiKey = apiKey
        logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)
        
    def getSubreports(self,masterReportId):
        uri = "reports/"+str(masterReportId)+"/subreports"
        return self.get(uri)
    
    def get(self,uri):
        opener = self.__getOpener()
        request = self.__buildRequest("GET",self.baseUrl + uri,"")
        connection = opener.open(request)
        response = connection.read()
        logging.debug("Response: " + response)
        return json.loads(response)
    
    def __getOpener(self):
        return urllib2.build_opener(urllib2.HTTPHandler)
    
    def __generateHmac(self,data):
        return hmac.new(self.apiKey.decode('hex'), msg=data, digestmod=hashlib.sha256).hexdigest()
        
    def __buildRequest(self,requestType,url,data):
        logging.debug(requestType + ": " + url + " with data: " + data)
        request = urllib2.Request(url,data=data)
        request.get_method = lambda:requestType
        request.add_header('Content-Type','application/json')
        request.add_header('Accept','application/json')
        request.add_header('X-LLNW-Security-Principal',self.username)
        timestamp = str(int(round(time.time()*1000)))
        request.add_header('X-LLNW-Security-Timestamp',timestamp)
        urlForHmac = url.partition("?")[0]
        logging.debug("Full Url: " + url)
        logging.debug("Url For Hmac: " + urlForHmac)
        queryParamsForHmac = url.partition("?")[2]
        logging.debug("Query Params For Hmac: " + queryParamsForHmac)
        request.add_header('X-LLNW-Security-Token', self.__generateHmac(requestType + urlForHmac + queryParamsForHmac + timestamp + data))
        logging.debug("Headers: " + str(request.headers))
        return request

    def getTrafficSummary(self,reportType,shortname,serviceType,reportId=None,startDate=None,reportDuration=ReportDuration.MONTH,filterField=None,searchItem=None,startItem=None,pageSize=None, endDate=None):
        uri = reportType
        uri += "?shortname=" + str(shortname)
        uri += "&service=" + str(serviceType)
        if reportId:
            uri += "&reportId=" + str(reportId)
        uri += "&reportDuration=" + str(reportDuration)
        if startDate: uri += "&startDate=" + str(startDate)
        if endDate: uri += "&endDate=" + str(endDate)
        if filterField: uri += "&filterField=" + str(filterField)
        if searchItem: uri += "&searchItem=" + str(searchItem)
        return self.get(uri)
    
def main():    
    # Client settings             #
    apiUrl = "http://control.llnw.com/traffic-reporting-api/v2/"
    apiKey = "c267483e4cadddecd03a1c935d874d3e16eabf3146d32a60c69a46331f8fb0a1"
    apiUser = "healthtalk-kleung"
    shortname = "healthtalk"
    api = TrafficReportingApi(apiUrl,apiUser,apiKey)
    
    year = str(datetime.now().year)
    month = str(datetime.now().month)
    if len(month) < 2:
        month = "0" + month
    day = "01"
    startDate = year + "-" + month + "-" + day
    endDate = "2014-04-21"
    #End Client Settings
    
    #Format Output
    #print ("Response for month of : " + startDate)
    usageTraffic = api.getTrafficSummary(TrafficReportType.SUMMARY, shortname=shortname, serviceType=ServiceType.HTTP, reportDuration=ReportDuration.MONTH, startDate=startDate, endDate=endDate )
    #print json.dumps(usageTraffic,sort_keys=True,indent=4)    
    #print ""
    #print "Usage for this Month so Far: "
    tbout = round(usageTraffic['responseItems'][0]['summary']['bytes']/1000000000000, 2)
    tbin = round(usageTraffic['responseItems'][0]['summary']['inbytes']/1000000000000, 2)
    
   
    tbtotal = tbout + tbin
    
    
    #Exit codes alerting
    if month in ['09', '04', '06', '11']:
        hoursinmonth = 30*24
    elif month in ['01', '03', '05', '07', '08', '10', '12']:
        hoursinmonth = 31*24
    else:
        hoursinmonth = 28*24
    dayofmonth = datetime.now().day
    hourofday = datetime.now().hour
    #print("Hour of day: " + str(hourofday))
    hourofmonth = dayofmonth*24 + hourofday
    #print("Hour of the month: " + str(hourofmonth))
    tblimit = 90.0
    linearusage = (float(hourofmonth)/float(hoursinmonth))*tblimit
  
    #print("")
    #print("Hours in this month: " + str(hoursinmonth))
    #print("Hour of the month: " + str(hourofmonth))
    
    #print("Calc: " + str(linearusage))   
    #print("Out: " + str(usageTraffic['responseItems'][0]['summary']['bytes']/1000000000000))
    #print("In: " + str(usageTraffic['responseItems'][0]['summary']['inbytes']/1000000000000))  
    #print("Total: " + str(tbtotal)) 
    print("Total: " + str(tbtotal) + " -- " + "Calc: " + str(linearusage) + " -- " + "Out: " + str(tbout) + " -- " + "In: " + str(tbin))
    #End Format Output
    
    #Exit Code Output
    if tbtotal > linearusage:
        sys.exit(2)
    else:
        sys.exit(0)
    
if __name__ == "__main__":
    main()    
