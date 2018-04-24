#/usr/bin/perl

use strict;
use warnings;
use IPC::Open3 qw(open3);

$| = 1;

my %oskeys=(
        'centos6-64bit' =>      '1-centos-66-x64-key',
        'centos6-32bit' =>      '1-centos-6-32bit-key',
        'centos5-64bit' =>      '1-centos-5-x64-key',
        'centos5-32bit' =>      '1-centos-5-32bit-key',
);

my %URLs=(
        'centos6-64bit' =>      'http://yum.spacewalkproject.org/2.3-client/RHEL/6/x86_64/spacewalk-client-repo-2.3-2.el6.noarch.rpm',
        'centos6-32bit' =>      'http://yum.spacewalkproject.org/2.3-client/RHEL/6/i386/spacewalk-client-repo-2.3-2.el6.noarch.rpm',
        'centos5-64bit' =>      'http://yum.spacewalkproject.org/2.3-client/RHEL/5/x86_64/spacewalk-client-repo-2.3-3.el5.noarch.rpm',
        'centos5-32bit' =>      'http://yum.spacewalkproject.org/2.3-client/RHEL/5/i386/spacewalk-client-repo-2.3-3.el5.noarch.rpm',
        'epel-5' => 'http://dl.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm',
        'epel-6' => 'http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm',
        'rhn-org' => 'http://usnjqa1lswalk01.waterfrontmedia.net/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm',

);

my $OS=`cat /etc/redhat-release`;
my $OS_Kernel = `uname -r`;
my $OS_arch = `uname -i`;
my $hostname = `hostname`;
chomp($hostname);

my @tmparr = split(/ /, $OS);
my $osversion = $tmparr[2];

my $iver="";
my $ever="";
chomp($OS_arch);
chomp($OS);
chomp($OS_Kernel);

if (($OS =~ m/6./) && ($OS_arch eq 'x86_64'))
{
        $iver = 'centos6-64bit';
        $ever = 'epel-6';
}
elsif (($OS =~ m/6./) && ($OS_arch eq 'i386'))
{
        $iver = 'centos6-32bit';
        $ever = 'epel-6';
}
elsif (($OS =~ m/5./) && ($OS_arch eq 'x86_64'))
{
        $iver = 'centos5-64bit';
        $ever = 'epel-5';
}
elsif (($OS =~ m/5./) && ($OS_arch eq 'i386'))
{
        $iver = 'centos5-32bit';
        $ever = 'epel-5';
}
else
{
        print "This server is not CentOS $OS_Kernel";
        exit 0;
}

my ($writer, $reader, $err, $retCode)=("","","","");
#my $cmd="rpm -Uvh $URLs{$iver}";
my $cmd="rpm -qa |grep spacewalk";
my $pid = open3($writer, $reader, $err, $cmd);
$retCode = <$reader>;
if ($retCode eq "")
{
        $cmd="rpm -Uvh $URLs{$iver}";
        $pid = open3($writer, $reader, $err, $cmd);
        print <$reader>;

}
$cmd="rpm -qa |grep epel-release";
$pid = open3($writer, $reader, $err, $cmd);
$retCode = <$reader>;
if ($retCode eq "")
{
        $cmd="rpm -Uvh $URLs{$ever}";
        $pid = open3($writer, $reader, $err, $cmd);
        print <$reader>;
}
$cmd="rpm -qa |grep rhn-client-tools";
$pid = open3($writer, $reader, $err, $cmd);
$retCode = <$reader>;
if ($retCode eq "")
{
        $cmd="yum install rhn-client-tools rhn-check rhn-setup rhnsd m2crypto yum-rhn-plugin osad -y";
        $pid = open3($writer, $reader, $err, $cmd);
        print <$reader>;
}
$cmd="rpm -qa |grep rhn-org-trusted-ssl-cert";
$pid = open3($writer, $reader, $err, $cmd);
$retCode = <$reader>;
if ($retCode eq "")
{
        $cmd="rpm -Uvh $URLs{'rhn-org'}";
        $pid = open3($writer, $reader, $err, $cmd);
        print <$reader>;
}

$cmd="spacewalk-channel -l";
$pid = open3($writer, $reader, $err, $cmd);
$retCode = <$reader>;
if ($retCode =~ m/Unable/)
{
	$cmd = "rhnreg_ks --serverUrl=https://usnjqa1lswalk01.waterfrontmedia.net/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=".$oskeys{$iver};
	$pid = open3($writer, $reader, $err, $cmd);
	my $str = <$reader>;
	if ($str eq "")
	{
		print "$hostname Server is registered successfully now. \n"
	}
	else
	{
		print "Unable to register and error is $str \n";	
	}	
}
else
{
	print "$hostname server is already registered into spacewalk \n";
}


$cmd="/sbin/service osad status";
$pid = open3($writer, $reader, $err, $cmd);
$retCode = <$reader>;
print "$retCode \n";
if ($retCode =~ m/stopped/)
{
        $cmd="/sbin/service osad start";
        $pid = open3($writer, $reader, $err, $cmd);
        $cmd="chkconfig --add osad; chkconfig --level 345 osad on";
        $pid = open3($writer, $reader, $err, $cmd);
}
