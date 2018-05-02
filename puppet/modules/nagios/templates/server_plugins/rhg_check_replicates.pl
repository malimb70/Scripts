#!/usr/bin/perl -w
use strict;

# 5/2/07	jdanilson	check that replicate is happy

# we check using show slave that both threads are running and that the time behind is zero 
# but we take it one step further and compare the db1 file position with our slave
# becasue we have seen at least one instance where the show slave command lies. 

# input arguments (required)
#	hostname  user password
my ($mysql_host,$mysql_user,$mysql_password)=@ARGV;
chomp($mysql_password);

# constants for warning.  x<low is ok.   x>high is error. otherwise warn. 
my $warn_low=5;	
my $warn_high=10;

# exit 0=0k, 1=warning, 2=error

use DBI;


#connect to primary database
my $dbh1=DBI->connect("DBI:mysql:;host=$mysql_host;port=3306",
	"$mysql_user", "$mysql_password",
	{ RaiseError => 0,
	PrintError => 0 });

if (!defined($dbh1)) {
		print "cannot connect to slave=$mysql_host\n";
		exit 2;
}

# first check, just get what the slave says
my ($master,$slave_master_pos,$slave_thread,$sql_state,$seconds_behind,@db1,$master_diff,$master_master_pos);
my $sth1=$dbh1->prepare("show slave status");

$sth1->execute() or die "execute 1 failed $DBI::errstr \n";
while (@db1=$sth1->fetchrow_array()) {
	$master=$db1[1];
	$slave_master_pos=$db1[6];
	$slave_thread=$db1[10];
	$sql_state=$db1[11];
	if (defined($db1[32])) {
		$seconds_behind=$db1[32];
	}
	else {
		$seconds_behind=-1;
	}
}

# check for basic goodness. bail if it's broken
if ($slave_thread eq 'Yes' && $sql_state eq 'Yes') { 
	# first evaluate and eliminate the obvious errors
	if ($seconds_behind==-1) {
		print "slave reports null seconds behind\n";
		exit 2;
	}
	if ($seconds_behind >$warn_low && $seconds_behind < $warn_high) {
		print "slave reports $seconds_behind seconds behind\n";
		exit 1;
	}
	if ($seconds_behind >=$warn_high) {
		print "slave reports $seconds_behind seconds behind\n";
		exit 2;
	}

	# now go check the master and compare where it is to where the slave is
	$dbh1=DBI->connect("DBI:mysql:;host=$master;port=3306",
		"$mysql_user", "$mysql_password",
		{ RaiseError => 0,
		PrintError => 0 });

	if (!defined($dbh1)) {
		print "cannot connect to master=$master\n";
		exit 1;
	}
	$sth1=$dbh1->prepare("show master status");
	$sth1->execute() or die "execute 2 failed $DBI::errstr \n";
	while (@db1=$sth1->fetchrow_array()) {
		$master_master_pos=$db1[1];
	}
	$master_diff=$master_master_pos-$slave_master_pos;
	if ($master_diff >$warn_low && $master_diff<$warn_high) {
		print "slave out of sync. difference=$master_diff\n";
		exit 1;
	}
	if ($master_diff>=$warn_high) {
		print "slave out of sync. difference=$master_diff\n";
		exit 2;
	}
}
else {
	print "at least one slave thread down.  slave=$slave_thread  sql=$sql_state\n";
	exit 2;
}

print "seconds behind=$seconds_behind\n";
exit 0;
