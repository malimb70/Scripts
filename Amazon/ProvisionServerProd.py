from Provision_AWS_v2 import *
import boto.ec2
from boto.ec2.networkinterface import NetworkInterfaceCollection
import base64
from boto.exception import EC2ResponseError

#Region We are connecting to and Project Name for Tags
region  = 'us-east-1'
Project = 'LiveLiveProd'

#Dry run or not, change to false to run
dry_run = 'False'

#Get User Data Function
def get_script(filename='C:\Users\cpan\workspace\python\Amazon\Userdata\Prod_Windows.ps1'):
    return open(filename).read()


#Server Definitions
servers = ('awsweh01', 'awsweh02', 'awswsql01', 'awswsql02', 'awslvcache01','awslvcache02' )
ips     = ('172.31.88.5', '172.31.96.5', '172.31.104.4', '172.31.105.4', '172.31.88.4', '172.31.96.4')
subnets = (get_subnet2("Prod_Web_East-1a", region=region), get_subnet2("Prod_Web_East-1b", region=region), get_subnet2("Prod-DB_East-1a", region=region), get_subnet2("Prod-DB_East-1b", region=region), get_subnet2("Prod_Web_East-1a", region=region), get_subnet2("Prod_Web_East-1b", region=region))
amis    = ('ami-73ef0618', 'ami-73ef0618', 'ami-f7957b9c', 'ami-f7957b9c', 'ami-2798324c', 'ami-2798324c')

for x in (2,3):
    try:
        
        print servers[x], ips[x], subnets[x], amis[x]
        webinterface = boto.ec2.networkinterface.NetworkInterfaceSpecification(subnet_id=subnets[x], associate_public_ip_address=True, groups=['sg-069db863', 'sg-8bffdcee', 'sg-7e38141b'], device_index=0, private_ip_address=ips[x])
        webinterfaces = boto.ec2.networkinterface.NetworkInterfaceCollection(webinterface)
        create_instance = make_ec2_instances_subnet(region=region, name=servers[x], network_interfaces=webinterfaces, ami=amis[x], dry_run=False, userdata=get_script(), Project=Project)
    except EC2ResponseError, e:
        print e
    
###### Create Network Interfaces
#interface1 = boto.ec2.networkinterface.NetworkInterfaceSpecification(subnet_id=subnet1, associate_public_ip_address=True, groups=['sg-069db863', 'sg-8bffdcee', 'sg-7e38141b'], device_index=0, private_ip_address=ip1)
#interfaces1_db_1a = boto.ec2.networkinterface.NetworkInterfaceCollection(interface1_db_1a)

#Create Instance
#Instance3 = make_ec2_instances_subnet(region=region, name=ServerName, network_interfaces=interfaces1_db_1a, ami=ami, dry_run=True)

