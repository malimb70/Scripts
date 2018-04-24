import boto
from boto.ec2.elb import HealthCheck
from Provision_AWS_v2 import *
import boto.ec2.elb
from boto.fps.exception import ResponseError
from boto.exception import BotoServerError

#Variables
lbname1          = 'EverydayHealth-SQL-LB-Test'
interval        = 5
timeout         = 3
target          = 'TCP:1433'
zones           = ['us-east-1a', 'us-east-1b']
region          = 'us-east-1'
listeners       = [(1433,1433, 'tcp')]
inst1name       = 'usnjwawssql01'
inst2name       = 'usnjwawssql02'
security_groups = ['sg-8bffdcee']

#Get Subnets
subnet3 = get_subnet2("Prod-DB_East-1a-Test", region=region)
subnet4 = get_subnet2("Prod-DB_East-1b-Test", region=region)
subnets    = [subnet3,subnet4]

#Get Instance ID
inst1 = get_ec2_instance(region=region, name=inst1name)
inst2 = get_ec2_instance(region=region, name=inst2name)
instances = [inst1, inst2]


#Define Health Check
hc = HealthCheck('healthCheck', 
                     interval=interval, 
                     target=target,
                     timeout=timeout)


#Create Load Balancer
try:
    Cheng = ''
    Cheng = get_elb(region=region, Name=lbname1)
    print Cheng
except BotoServerError as e:
    print "LB already exists"

if len(Cheng) == 0:
    lb = create_elb(region, name=lbname1, zones=None, listeners=listeners, subnets=subnets, hc=hc, security=security_groups, scheme='internal')
    lb.register_instances(instances)
else:
    print "Load Balancer exists"    

#lb = create_elb(region, name=lbname, zones=None, listeners=listeners, subnets=subnets, hc=hc)
#lb.register_instances(instances)


