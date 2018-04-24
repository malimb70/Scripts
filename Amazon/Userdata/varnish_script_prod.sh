#!/bin/bash -ex
#Set AWS Params
export Instance_ID=`curl --silent http://169.254.169.254/latest/meta-data/instance-id`
export AWSHOSTNAME=`aws ec2 describe-tags --filter "Name=resource-id, Values=${Instance_ID}" "Name=key, Values=Name" | egrep -oh 'usnj[a-z]+[0-9]+'`
#Set Hostname
hostname ${AWSHOSTNAME}.waterfrontmedia.net
sed -i '/HOSTNAME/d' /etc/sysconfig/network
echo "HOSTNAME=${AWSHOSTNAME}.waterfrontmedia.net" >> /etc/sysconfig/network

#Resolv.conf
sed -i '/search/d' /etc/resolv.conf
sed -i '/nameserver/d' /etc/resolv.conf
echo "search waterfrontmedia.net" >> /etc/resolv.conf
echo "nameserver 10.133.105.10" >> /etc/resolv.conf
echo "nameserver 10.133.105.11" >> /etc/resolv.conf
chattr +i /etc/resolv.conf

#Set Selinux
sed -i 's/enforcing/permissive/g'/etc/selinux/config
