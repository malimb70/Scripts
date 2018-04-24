from Provision_AWS_v2 import *

#Secret Key Information
access_key       = ''
secret_key       = ''

#Region and VPC Information
vpc_id           = 'vpc-3ab71d5f'
region           = 'us-east-1'

##Subnet information
#Subnet 1
subnet1_name = 'Prod-DB_East-1b'
availability_zone1 = 'us-east-1b'
network_aclname1 = 'Prod-DB_East-1b'
cidr_block1 = '172.31.105.0/24'

#Subnet 2
subnet2_name = 'Prod_Web_East-1b'
availability_zone2 = 'us-east-1b'
network_aclname2 = 'Prod_Web_East-1b'
cidr_block2 = '172.31.96.0/21'

#Subnet 3
subnet3_name = 'Prod_Web_East-1a'
availability_zone3 = 'us-east-1a'
network_aclname3 = 'Prod_Web_East-1a'
cidr_block3 = '172.31.88.0/21'

#Subnet 4
subnet4_name = 'Prod-DB_East-1a'
availability_zone4 = 'us-east-1a'
network_aclname4 = 'Prod-DB_East-1a'
cidr_block4 = '172.31.104.0/24'



############  Begin Buildout   ##################

#Connect to VPC
vpc = VPCConnection(aws_access_key_id=access_key, aws_secret_access_key=secret_key)
    

#Create the Network ACLs
if len(get_nacl(name=network_aclname2, region=region)) == 0:
    nacl2 = create_nacl(vpc_id=vpc_id, region=region, network_aclname=network_aclname2)
    
    ########################## Create Network Acls entries for Network ACL created above  ######################
    
    #network-aclname2
    
    ######### Inbound Rules ##########
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=1, protocol=6, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=2, protocol=17, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=10, protocol=6, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=11, protocol=17, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=20, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=49152, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=21, protocol=17, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=32768, port_range_to=61000 )
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=30, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=80, port_range_to=80 )
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=31, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=443, port_range_to=443 )
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=40, protocol=1, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=41, protocol=1, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    
    ######### Outbound Rules ##########
    vpc.create_network_acl_entry(network_acl_id=nacl2, rule_number=1, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )

else:
    print "Network ACL " + network_aclname2 + " already exists"

if len(get_nacl(name=network_aclname4, region=region)) == 0:
    nacl4 = create_nacl(vpc_id=vpc_id, region=region, network_aclname=network_aclname4)
    
    ########################## Create Network Acls entries for Network ACL created above  ######################
    
    #network-aclname4
    
     ######### Inbound Rules ##########
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=1, protocol=6, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=2, protocol=17, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=10, protocol=6, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=11, protocol=17, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=20, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=49152, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=21, protocol=17, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=32768, port_range_to=61000 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=30, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=80, port_range_to=80 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=40, protocol=1, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=41, protocol=1, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    
    ######### Outbound Rules ##########
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=1, protocol=6, rule_action='Allow', cidr_block='172.31.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=2, protocol=17, rule_action='Allow', cidr_block='172.31.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=10, protocol=6, rule_action='Allow', cidr_block='10.133.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=11, protocol=17, rule_action='Allow', cidr_block='10.133.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=20, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=1, port_range_from=80, port_range_to=80 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=21, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=1, port_range_from=443, port_range_to=443 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=30, protocol=1, rule_action='Allow', cidr_block='10.133.0.0/16', egress=1, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    vpc.create_network_acl_entry(network_acl_id=nacl4, rule_number=40, protocol=1, rule_action='Allow', cidr_block='172.31.0.0/16', egress=1, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
else:
    print "Network ACL " + network_aclname4 + " already exists"

    
if len(get_nacl(name=network_aclname1, region=region)) == 0:
    nacl1 = create_nacl(vpc_id=vpc_id, region=region, network_aclname=network_aclname1)
    
    #network-aclname1
    
     ######### Inbound Rules ##########
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=1, protocol=6, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=2, protocol=17, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=10, protocol=6, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=11, protocol=17, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=20, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=49152, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=21, protocol=17, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=32768, port_range_to=61000 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=30, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=80, port_range_to=80 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=40, protocol=1, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=41, protocol=1, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    
    
    ######### Outbound Rules ##########
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=1, protocol=6, rule_action='Allow', cidr_block='172.31.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=2, protocol=17, rule_action='Allow', cidr_block='172.31.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=10, protocol=6, rule_action='Allow', cidr_block='10.133.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=11, protocol=17, rule_action='Allow', cidr_block='10.133.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=20, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=1, port_range_from=80, port_range_to=80 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=21, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=1, port_range_from=443, port_range_to=443 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=30, protocol=1, rule_action='Allow', cidr_block='10.133.0.0/16', egress=1, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    vpc.create_network_acl_entry(network_acl_id=nacl1, rule_number=40, protocol=1, rule_action='Allow', cidr_block='172.31.0.0/16', egress=1, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
else:
    print "Network ACL " + network_aclname1 + " already exists"

if len(get_nacl(name=network_aclname3, region=region)) == 0:
    nacl3 = create_nacl(vpc_id=vpc_id, region=region, network_aclname=network_aclname3)
    
    #network-aclname3
    
    ######### Inbound Rules ##########
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=1, protocol=6, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=2, protocol=17, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=10, protocol=6, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=11, protocol=17, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=20, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=49152, port_range_to=65535 )
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=21, protocol=17, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=32768, port_range_to=61000 )
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=30, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=80, port_range_to=80 )
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=31, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/0', egress=0, port_range_from=443, port_range_to=443 )
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=40, protocol=1, rule_action='Allow', cidr_block='10.133.0.0/16', egress=0, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=41, protocol=1, rule_action='Allow', cidr_block='172.31.0.0/16', egress=0, port_range_from=0, port_range_to=0, icmp_code=-1, icmp_type=-1 )
    
    
    ######### Outbound Rules ##########
    vpc.create_network_acl_entry(network_acl_id=nacl3, rule_number=1, protocol=6, rule_action='Allow', cidr_block='0.0.0.0/16', egress=1, port_range_from=0, port_range_to=65535 )

    ###############################################################################################################

else:
    print "Network ACL " + network_aclname3 + " already exists"

#Create subnet
if len(get_subnet(name=subnet1_name, region=region)) == 0:
    subnet1 = create_subnet(vpc_id=vpc_id, cidr_block=cidr_block1, availability_zone=availability_zone1, subnet_name=subnet1_name, region=region)
    vpc.associate_network_acl(nacl1, subnet1)
else:
    print "Subnet " + subnet1_name + " already exists"
    
if len(get_subnet(name=subnet2_name, region=region)) == 0:
    subnet2 = create_subnet(vpc_id=vpc_id, cidr_block=cidr_block2, availability_zone=availability_zone2, subnet_name=subnet2_name, region=region)
    vpc.associate_network_acl(nacl2, subnet2)
else:
    print "Subnet " + subnet2_name + " already exists"
    
if len(get_subnet(name=subnet3_name, region=region)) == 0:
    subnet3 = create_subnet(vpc_id=vpc_id, cidr_block=cidr_block3, availability_zone=availability_zone3, subnet_name=subnet3_name, region=region)
    vpc.associate_network_acl(nacl3, subnet3)
else:
    print "Subnet " + subnet3_name + " already exists"
    
if len(get_subnet(name=subnet4_name, region=region)) == 0:
    subnet4 = create_subnet(vpc_id=vpc_id, cidr_block=cidr_block4, availability_zone=availability_zone4, subnet_name=subnet4_name, region=region)
    vpc.associate_network_acl(nacl4, subnet4)
else:
    print "Subnet " + subnet4_name + " already exists"



#Create Instances inside our subnet
#inst1 = make_ec2_instances_subnet(region=region, name=name1, subnet=subnet1)
#inst2 = make_ec2_instances_subnet(region=region, name=name2, subnet=subnet2 )
