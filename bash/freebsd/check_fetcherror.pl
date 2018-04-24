#!/usr/local/bin/perl -w

use strict;

use Getopt::Long;
use lib "/usr/local/libexec/nagios";
use utils qw($TIMEOUT %ERRORS &print_revision &support &usage);
use vars qw($PROGNAME $verbose);

$PROGNAME = "check_fetcherror.pl";
$TIMEOUT = 60;

sub print_help ();
sub print_usage {
        print << "EOF";

usage: $PROGNAME <site name>

EOF
        exit 1;
}

my $VARNISHTOP = "/usr/local/bin/varnishtop";
my $line = `$VARNISHTOP -i FetchError -1`;
chomp $line;

#
# 1.00 FetchError no backend connection
#
my ($num,$etype) = $line =~ /\s+(\d+\.\d+)\s+(.*?)$/;
if (defined $&) {
	$num += 0.0;
	if ( $etype =~ /no backend/ && $num > 10.0 ) {
		print "CRITICAL: Fetch error: ${num}: ${etype}.\n";
		exit $ERRORS{'CRITICAL'};
	} elsif ( $etype =~ /backend write error/ && $num > 10.0 ) {
		print "WARNING: Fetch error: ${num}: ${etype}\n";
		exit $ERRORS{'WARNING'};
	} elsif ( $etype =~ /http first read error/ && $num > 10.0 ) {
		print "WARNING: Fetch error: ${num}: ${etype}\n";
		exit $ERRORS{'WARNING'};
	}
} else {
	print "OK: No fetch errors.\n";
	exit $ERRORS{'OK'};
}
