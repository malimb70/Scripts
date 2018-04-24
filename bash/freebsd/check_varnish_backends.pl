#!/usr/local/bin/perl -w

use strict;
use Data::Dumper;
use Getopt::Long;
use lib "/usr/local/libexec/nagios";
use utils qw($TIMEOUT %ERRORS &print_revision &support);
use vars qw($PROGNAME $verbose $opt_V $opt_H);

$PROGNAME = "check_varnish_backends.pl";

sub usage {
	my $reason = shift;
	print << "EOF";

usage: $PROGNAME -H <IP Address>
$reason
EOF
exit $ERRORS{'UNKNOWN'};
}

sub parse_config {
	my %backend = ();

	opendir(my $dir, "/usr/local/etc/varnish/backends") or die "$!";
	while (readdir $dir) {
		if ($_ =~ /_backends/) {
			my $current = $_;
			open (CURR, "< /usr/local/etc/varnish/backends/$current") or die "$!";
			my ($be, $ip, $host);
			while(<CURR>) {
				if ( /backend\s+(.*?)\s*\{/ ) {
					$be = $1;
					next;
				}
				if ( /\s+\.host\s+=\s+\"(\d+\.\d+\.\d+\.\d+)\"/ ) {
					$ip = $1;
					push @{$backend{$ip}}, $be;
					next;
				}
				if ( /\s+.host_header\s+=\s+\"(.*?)\"/ ) {
					$host = $1;
					push @{$backend{$ip}}, $1;
					next;
				}
			}	
			close CURR;
		}
	}
	close $dir;
	return %backend;
}

Getopt::Long::Configure('bundling');
GetOptions
        ("v"  => \$verbose, "verbose"  => \$verbose,
        "V"   => \$opt_V, "version"    => \$opt_V,
        "H=s" => \$opt_H, "host"       => \$opt_H);

($opt_H) || ($opt_H = shift);
!defined $opt_H && usage;

my $ipwanted = $1 if ($opt_H =~ /^(([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5]))$/);
($ipwanted) || usage("Invalid IP address: $opt_H.\n");

my %backends = &parse_config;
my %varnishadm = ();

open(VARNISHADM, "/usr/local/bin/varnishadm -T localhost:81 debug.health |") or die "$!";
while(<VARNISHADM>) {
	if (/^Backend\s+(\S+)\s+is\s+(\w+)/) {
		$varnishadm{"$1"} = $2;
	}	
}

if ( !defined $backends{"$ipwanted"}[0] or !defined $varnishadm{$backends{"$ipwanted"}[0]} ) {
	usage("IP not used in Varnish");
}

print $ipwanted . " is a part of " . $backends{"$ipwanted"}[0] . " and is currently " . $varnishadm{$backends{"$ipwanted"}[0]} . "\n";
if ($varnishadm{$backends{"$ipwanted"}[0]} eq "Healthy") {
	exit $ERRORS{'OK'};
} elsif ($varnishadm{$backends{"$ipwanted"}[0]} eq "Sick") {
	exit $ERRORS{'CRITICAL'};
}
