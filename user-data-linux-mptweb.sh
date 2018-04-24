#!/bin/bash

touch /tmp/completed

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

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDci6vj8HKLT4Dc0U6RNxMAzxu8zcLbXU0WW5u2nQj5lJUjhkA22DsACeBZitCw5AHCX3i9401iZyOO64AD11/trgkvfu5fYA+xh4teKk10JR+skReKUP3wd8uqWkwXy6GyGKUxdAzslVXeGQxKPvtQv7AdNiKcoQv9n/WYSCEVO/ZrsG/s0JvLg+HIeg9tzmCdH0kzTxK9AlRW/iy1822SQfMAavUggQXALOcsNgqHTMhsvJlb4zW8iENkz+CMZgWdZYx6Lhb/N5mD9QRYs8Mk3H2JN1o/Gw7mF9vN1odXW85twbefpP67wTLmqT5phaib1sdSk7ifXFvHXg09bHq5 root@usnjlswalk01.waterfrontmedia.net" >> /root/.ssh/authorized_keys
hostname HNAME
echo 'HNAME' > /proc/sys/kernel/hostname
yum install wget sshpass ntpdate -y
ntpdate 10.133.105.37
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

CC="echo 'HNAME' |cut -d'.' -f1 | awk '{print substr($0,length,2)}'"
C1=` expr $CC % 2`

if [ "$C1" == "1" ]
then
    if [ `hostname` =~ /^mptstgl/ ]
    then
        echo "172.30.32.52:/ /mnt/medpage_static-htmls nfs defaults,vers=4.1 0 0" >> /etc/fstab
        echo "172.30.32.68:/ /mnt/medpage_stg_php_content nfs defaults,vers=4.1 0 0" >> /etc/fstab
    else 
        echo "172.30.20.90:/ /mnt/medpage_static-htmls nfs defaults,vers=4.1 0 0" >> /etc/fstab
        echo "172.30.20.88:/ /mnt/medpage_php_content nfs defaults,vers=4.1 0 0" >> /etc/fstab
    fi  
else
    if [ `hostname` =~ /^mptstgl/ ]
    then
        echo "172.30.32.52:/ /mnt/medpage_static-htmls nfs defaults,vers=4.1 0 0" >> /etc/fstab
        echo "172.30.33.55:/ /mnt/medpage_stg_php_content nfs defaults,vers=4.1 0 0" >> /etc/fstab
    else 
        echo "172.30.21.225:/ /mnt/medpage_static-htmls nfs defaults,vers=4.1 0 0" >> /etc/fstab
        echo "172.30.21.244:/ /mnt/medpage_php_content nfs defaults,vers=4.1 0 0" >> /etc/fstab
    fi   
fi
yum install -y nfs-utils
mkdir /mnt/medpage_static-htmls
mkdir /mnt/medpage_php_content
mount -av
service smb restart
service winbind restart
chkconfig --level 345 smb on
chkconfig --level 345 winbind on
sed -i '6ipreserve_hostname: true' /etc/cloud/cloud.cfg

echo "100" > /tmp/completed
