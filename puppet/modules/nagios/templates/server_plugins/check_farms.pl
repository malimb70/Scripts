#!/usr/bin/perl -w

# get farms OID
# .1.3.6.1.4.1.89.35.1.13.1.2
# get hosts OID
# .1.3.6.1.4.1.89.35.1.11.1.4

use strict;
use Getopt::Long;
use lib "/usr/lib/nagios/plugins";
use utils qw($TIMEOUT %ERRORS &print_revision &support &usage);
use vars qw($PROGNAME $opt_V $opt_h $opt_H $opt_i $verbose);

$PROGNAME = "check_farms.pl";
$TIMEOUT = 60;

sub print_help ();
sub print_usage {
	print << "EOF";

usage: $PROGNAME -H <radware ip address> -i <comma separated list of ips>

EOF
	exit 1;
}

Getopt::Long::Configure('bundling');
GetOptions
        ("v"  => \$verbose, "verbose"  => \$verbose,
        "V"   => \$opt_V, "version"    => \$opt_V,
        "h"   => \$opt_h, "help"       => \$opt_h,
        "H=s" => \$opt_H, "hostname"   => \$opt_H,
	"i=s" => \$opt_i, "ips"        => \$opt_i);

if ($opt_V) {
	print_revision($PROGNAME,'$ Revision: 1.0 $');
	exit $ERRORS{'OK'};
}

if ($opt_h) {
	print_help();
	exit $ERRORS{'OK'};
}

($opt_H) || ($opt_H = shift);
!defined $opt_H && print_usage;
my $radware = $1 if ($opt_H =~ /^(([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5]))$/);
($radware) || usage("Invalid Radware IP address: $opt_H\n");

($opt_i) || ($opt_i = shift);
!defined $opt_i && print_usage;
my $ip = $1 if ($opt_i =~ /^(((([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])),?)+)$/);
($ip) || usage("Invalid farm IP address: $opt_i\n");
$ip =~ s/ //g;
my @ips = split /,/, $ip;

my %farm = ();
my %host = ();
my %dontcare = ();
my %errors = ();
my %varnish = ();

open(NOCARE, "< /etc/nagios/dontcheckips") or die "$!";
while (<NOCARE>) {
	chomp;
	$dontcare{$_}++;
}
close NOCARE;

open(VARNISH, "< /etc/nagios/weusevarnish") or die "$!";
while (<VARNISH>) {
	chomp;
	next if /^#/;
	my ($ip, $path) = split / /;
	$varnish{$ip} = $path;
}
close VARNISH;

$SIG{'ALRM'} = sub {
        print "No Answer from Radware\n";
        exit $ERRORS{"UNKNOWN"};
};
alarm($TIMEOUT);

my @allfarms = `/usr/bin/snmpwalk -c wfm45MIB -v1 $radware .1.3.6.1.4.1.89.35.1.13.1.2`;
my @allhosts = `/usr/bin/snmpwalk -c wfm45MIB -v1 $radware .1.3.6.1.4.1.89.35.1.11.1.4`;

foreach my $reply (@allfarms) {
	my ($id, $farmname) = $reply =~ /SNMPv2-SMI::enterprises.89.35.1.13.1.2.0.0.(\d+\.\d+) = STRING: \"(\S+)\"/;
	$farm{$id} = $farmname;
}

foreach my $reply (@allhosts) {
	my ($id, $hostip, $port, $status) = $reply =~ /SNMPv2-SMI::enterprises.89.35.1.11.1.4.0.0.(\d+\.\d+)\.(\d+\.\d+\.\d+\.\d+)\.(\d+) = INTEGER: (\d+)/;
	push @{$host{$id}}, "$hostip:$port:$status";
}

my @bad = ();
my @checkforvarnish = ();

foreach my $id (sort keys %host) { # go through the list of ids in the host hash
	foreach my $ipinid (@{$host{$id}}) { # and go though each ip address in that entry
		my @realip = split /:/, $ipinid;
		foreach my $ipstocheck (@ips) { # get each ip to check from what was entered on the cmdline
			if ($realip[0] eq $ipstocheck) {
				if (exists $varnish{$ipstocheck}) {
					push @checkforvarnish, $ipstocheck unless exists {map { $_ => 1 } @checkforvarnish}->{$ipstocheck};
				# print "$realip[0] matches $ipstocheck in farm ", $farm{$id}, " and its status is $realip[2]\n";
				} elsif ($realip[2] ne "1") { # is it in the farm?
					push @bad, "$id:$realip[0]";
				}
			}
		}
	}
}

my @badvarnish = ();
foreach my $v (@checkforvarnish) {
	my $returncode = system("/usr/lib/nagios/plugins/check_nrpe -H $v -c check_file_exists -a $varnish{$v} > /dev/null 2>&1");
	if ($returncode != 0) {
		push @badvarnish, $v;
	}
}

# skip the farms that end in 2, they are for testing and get rid of the don't care list
if (@bad) {
	my $i = 0;
	foreach (@bad) {
               	my @baddies = split /:/, $bad[$i];
               	if ( $farm{$baddies[0]} =~ /2/ || $dontcare{$baddies[1]} ) {
			delete $bad[$i];
               	}
		$i++;
	}
}

# now we have all the real bad ones
if (@bad or @badvarnish) {
	print "CRITICAL: ";
	foreach my $b (@bad) {
		my @baddies = split /:/, $b;
		print $farm{$baddies[0]}, " has ", $baddies[1], " out.." if ($farm{$baddies[0]} ne "");
	}
	foreach my $bv (@badvarnish) {
		print $bv . " out of varnish..";
	}
} else {
	print "OK: Nothing out of the farm";
}
print "\n";

if (@bad or @badvarnish) {
	exit $ERRORS{'CRITICAL'};
} else {
	exit $ERRORS{'OK'};
}
