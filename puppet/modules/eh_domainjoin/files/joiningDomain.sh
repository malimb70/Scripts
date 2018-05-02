#!/bin/sh
#Script for checking whether krb5.conf and samba configuration looks fine

user=$1
pass=$2

checkNTPWorking()
{
    dnsip=$1
	if [[ "$os" =~ 7 ]]
	then
		/usr/bin/systemctl stop ntpd
		/usr/sbin/ntpdate $disip
		/usr/bin/systemctl start ntpd
	else
		/sbin/service winbind stop
		/sbin/service smb restart
		/sbin/service winbind start
	fi
}

function restartAD()
{
	if [[ "$os" =~ 7 ]]
	then
		/usr/bin/systemctl stop winbind.service
		/usr/bin/systemctl restart smb.service
		/usr/bin/systemctl start winbind.service
	else
		/sbin/service winbind stop
		/sbin/service smb restart
		/sbin/service winbind start
	fi
}

function checkADJoin()
{
	dnsip=$1
	dchost=$2
	CC=`getent passwd svc_puppet |wc -l`
	if [ "$CC" == "0" ]
	then

        domain_det=`grep 'admin_server' /etc/krb5.conf |cut -d"=" -f2 |tail -1 |sed -e 's/^[ \t]*//'`
        if [[ "$domain_det" =~ ^$dchost* ]]
        then
            checkNTPWorking $dnsip
            restartAD
            if [ `rpm -qa |grep sshpass |wc -l` == "0" ]
            then
				yum -y install sshpass
            fi

            echo $pass > /tmp/.pass.txt
            sshpass -f /tmp/.pass.txt net ads join -U $user
            rm -f /tmp/.pass.txt

            if [ `rpm -qa |grep authconfig |wc -l` == "0" ]
            then
				yum -y install authconfig
            fi
			restartAD
            authconfig --enablemkhomedir --enablewinbind --enablewinbindauth --update

            if [ `wbinfo -u |grep $user |wc -l` == "1" ]
            then
				return "Successfully joined into Domain"
            else
				return "Failed to domain, check it out setting manually"
            fi
            exit 0
         else
            return "check wrong Windows DC is pointing"
            exit 1
         fi
  else
        echo "Already server is in domain"
		exit 0
  fi
}

os=`facter |grep operatingsystemmajrelease |cut -d">" -f2`

hostname=`hostname`
if [[ "$hostname" =~ ^usnjdev* ]] || [[ "$hostname" =~ ^usnjqa1* ]]
then
 checkADJoin 10.133.125.11 usnjwdc06
elif [[ "$hostname" =~ ^usnjl* ]] || [[ "$hostname" =~ ^usnjstg* ]]
then
  checkADJoin 10.133.105.37 usnjwdc04
elif [[ "$hostname" =~ ^aws* ]]
then
 checkADJoin 172.31.22.107 awsewdc07
fi

