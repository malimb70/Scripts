#!/bin/bash

setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
/etc/init.d/sshd restart

OSv=`cat /etc/redhat-release |cut -d' ' -f3`
H=`cat /etc/sysconfig/network |grep 'HOSTNAME' |wc -l`
if [ "$H" == 0 ]
then
        echo "HOSTNAME=HNAME" >> /etc/sysconfig/network
else
        sed -i 's/.*HOSTNAME.*/HOSTNAME=HNAME/' /etc/sysconfig/network
fi
hostname HNAME
echo 'HNAME' > /proc/sys/kernel/hostname
yum install wget sshpass ntpdate -y
ntpdate 172.31.22.107

chattr -i /etc/resolv.conf
wget http://10.133.105.101/packages/resolv.conf-temp -O /etc/resolv.conf
chattr +i /etc/resolv.conf
wget http://10.133.105.101/packages/puppetlabs-release-6-12.noarch.rpm -O /tmp/puppetlabs-release-6-12.noarch.rpm
rpm -ivh /tmp/puppetlabs-release-6-12.noarch.rpm
yum -y install puppet

wget http://10.133.105.101/packages/puppet.conf-temp -O /etc/puppet/puppet.conf
sed -i 's/HOSTNAME/HNAME/' /etc/puppet/puppet.conf
puppet agent -t
puppet agent -t
C1=`getent passwd sraju |wc -l`
if [ "$C1" == "0" ]
then
  puppet agent -t
fi

yum -y install perl-DBD-MySQL
useradd mysql
usermod -G mysql tuscmysql