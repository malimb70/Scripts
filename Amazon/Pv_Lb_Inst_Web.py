import boto
from boto.ec2.elb import HealthCheck
from Provision_AWS_v2 import *
import boto.ec2.elb
from boto.fps.exception import ResponseError
from boto.exception import BotoServerError

#Variables
lbname1          = 'EverydayHealth-Platform-LB-Test'
interval        = 5
timeout         = 3
target          = 'TCP:80'
zones           = ['us-east-1a', 'us-east-1b']
region          = 'us-east-1'
listeners       = [(80,80, 'http'),(443,80, 'tcp')]
inst1name       = 'usnjlawsvcache01'
inst2name       = 'usnjlawsvcache02'
security_groups = ['sg-7e38141b']

#Get Subnets
subnet1 = get_subnet2("Prod_Web_East-1a-Test", region=region)
subnet2 = get_subnet2("Prod_Web_East-1b-Test", region=region)
subnets    = [subnet1,subnet2]

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
    lb = create_elb(region, name=lbname1, zones=None, listeners=listeners, subnets=subnets, hc=hc, security=security_groups)
    lb.register_instances(instances)
else:
    print "Load Balancer exists"    

#lb = create_elb(region, name=lbname, zones=None, listeners=listeners, subnets=subnets, hc=hc)
#lb.register_instances(instances)


