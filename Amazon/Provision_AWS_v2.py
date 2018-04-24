import boto.ec2
import argparse
import time
import boto.ec2.elb
from boto.regioninfo import RegionInfo
from boto.vpc import VPCConnection

#Secret Key Information
access_key       = ''
secret_key       = ''


#Get Instance Information       
def get_ec2_instances(region):
    ec2_conn = boto.ec2.connect_to_region(region,
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key)
    reservations = ec2_conn.get_all_reservations()
    for reservation in reservations:    
        instances = reservation.instances
        inst = instances[0]
        print ((inst.tags['Name'],inst.instance_type,inst.placement, inst.state, inst.private_dns_name, inst.id, inst.subnet_id, reservation, inst.interfaces))
   
def get_ec2_instance(region, name):
    ec2_conn = boto.ec2.connect_to_region(region,
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key)
    reservations = ec2_conn.get_all_reservations(filters={'tag-value': name})

    for reservation in reservations:    
        instances = reservation.instances
        inst = instances[0]
        print inst.state
        return inst.id
        
       
#Make EC2-Instance EH
def make_ec2_instances_subnet(region,name, subnet=None, network_interfaces=None, security_group_ids=None, ami=None, userdata=None, Project='LiveLiveProject', dry_run=False):
    ec2_conn = boto.ec2.connect_to_region(region,
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key)
    reservations = ec2_conn.run_instances(ami, key_name='liveliveaws', instance_type='m3.large', security_group_ids=security_group_ids, instance_profile_name='Get-EC2Tag', subnet_id=subnet, network_interfaces=network_interfaces, user_data=userdata, dry_run=dry_run)
    newinstanceid = reservations.instances[0]
    id = str(newinstanceid)
    id = (id.split(":"))[1]    
    
    time.sleep(1)
    ec2_conn.create_tags(id, {"Name": name, "Project": Project})
    return id
    
def make_ec2_instances(region,name, subnet):
    ec2_conn = boto.ec2.connect_to_region(region,
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key)
    reservations = ec2_conn.run_instances('ami-73ef0618', key_name='liveliveaws', instance_type='m3.large', security_group_ids=None, instance_profile_name='Get-EC2Tag')
    newinstanceid = reservations.instances[0]
    id = str(newinstanceid)
    id = (id.split(":"))[1]    
    
    time.sleep(1)
    ec2_conn.create_tags(id, {"Name": name, "Project": 'liveliveProject'})
    return id

#Make EC2-Instance SQL
def make_ec2_instances_sql(region,name):
    ec2_conn = boto.ec2.connect_to_region(region,
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key)
    reservations = ec2_conn.run_instances('ami-d701e1bc', key_name='liveliveaws', instance_type='m3.large', security_groups=['Carlstadt-Sungard', 'RDP_access_345', 'AWS_Internal', 'SSH from 345 Hudson'], instance_profile_name='Get-EC2Tag')
    newinstanceid = reservations.instances[0]
    id = str(newinstanceid)
    id = (id.split(":"))[1]    
    
    time.sleep(1)
    ec2_conn.create_tags(id, {"Name": name, "Project": 'liveliveProject'})
    
#Make Load Balancer    
def get_elb(region, Name):
    #Get ElBConnection Object
    elb = boto.ec2.elb.connect_to_region(region)
    
    #Split object to get Endpoing
    reg = str(elb).split(':',1)[1]
    
    #Set the region
    elb_region = boto.regioninfo.RegionInfo(
                name=region, 
                endpoint=reg)
    
    #Connect to Region
    elb_connection = boto.connect_elb(
                aws_access_key_id=access_key, 
                aws_secret_access_key=secret_key, 
                region=elb_region)
    
    #Get all load balancers in the specified region
    load_balancer = elb_connection.get_all_load_balancers(load_balancer_names=Name)
    for i in load_balancer:
        return i.dns_name

def create_elb(region, name=None, zones=None, listeners=None, subnets=None, security=None, hc=None, scheme='internet-facing'):
    elb = boto.ec2.elb.connect_to_region(region)
    reg = str(elb).split(':',1)[1]
    elb_region = boto.regioninfo.RegionInfo(
                name=region, 
                endpoint=reg)
    elb_connection = boto.connect_elb(
                aws_access_key_id=access_key, 
                aws_secret_access_key=secret_key, 
                region=elb_region)
   
    lb = elb_connection.create_load_balancer(name, zones,
                                   listeners, subnets, security_groups=security, scheme=scheme)
    lb.configure_health_check(hc)
    
    get_elb(region, name)
    print lb.dns_name
    return lb

def create_subnet(vpc_id, cidr_block, availability_zone, subnet_name, region):
    vpc = VPCConnection(aws_access_key_id=access_key, aws_secret_access_key=secret_key)
    datacenters = vpc.create_subnet(vpc_id=vpc_id, cidr_block=cidr_block, availability_zone=availability_zone)
        
    ec2_conn = boto.ec2.connect_to_region(region,
                    aws_access_key_id=access_key,
                    aws_secret_access_key=secret_key)
    time.sleep(1)
    ec2_conn.create_tags(datacenters.id, {"Name": subnet_name, "Project": 'LiveLiveProd'})
    return datacenters.id
    
def create_nacl (vpc_id, region, network_aclname):
    
    vpc = VPCConnection(aws_access_key_id=access_key, aws_secret_access_key=secret_key)
    network = vpc.create_network_acl(vpc_id)
    time.sleep(1)
    ec2_conn = boto.ec2.connect_to_region(region,
                    aws_access_key_id=access_key,
                    aws_secret_access_key=secret_key)
    ec2_conn.create_tags(network.id, {"Name": network_aclname , "Project": 'LiveLiveProd'})
    return network.id

def get_nacl(name, region):
    vpc = VPCConnection(aws_access_key_id=access_key, aws_secret_access_key=secret_key)
    nacl = vpc.get_all_network_acls(filters={'tag-value': name})
    return nacl

def get_subnet(name, region):
    vpc = VPCConnection(aws_access_key_id=access_key, aws_secret_access_key=secret_key)
    subnet = vpc.get_all_subnets(filters={'tag-value': name})
    return subnet

def get_subnet2(name, region):
    vpc = VPCConnection(aws_access_key_id=access_key, aws_secret_access_key=secret_key)
    subnet = vpc.get_all_subnets(filters={'tag-value': name})
    subnetid = str(subnet)
    subnetid = (subnetid.split(":"))[1] 
    subnetid = subnetid.replace("]", '')
    return subnetid