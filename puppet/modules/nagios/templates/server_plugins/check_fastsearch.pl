#!/usr/bin/perl -w

use strict;
use Getopt::Long;
use Time::HiRes qw( gettimeofday tv_interval );
use vars qw($opt_t $opt_V $opt_h $opt_w $opt_c $verbose);
use vars qw($PROGNAME);
use lib "/usr/lib/nagios/plugins";
use utils qw($TIMEOUT %ERRORS &print_revision &support &usage);

sub print_help ();
sub print_usage ();

$PROGNAME = "check_fastsearch.pl";
$TIMEOUT = 60;

$ENV{'PATH'}='';
$ENV{'BASH_ENV'}='';
$ENV{'ENV'}='';

my $CURL = -x "/usr/bin/curl" ? ("/usr/bin/curl") : (-x "/usr/local/bin/curl" ? ("/usr/local/bin/curl") : undef);
if (!defined $CURL) {
	print "cURL not installed on this machine!\n";
	exit $ERRORS{'UNKNOWN'};
}

my $URL = "http://10.133.105.126:15100/cgi-bin/view/flp/everydayhealthregexsppublished?offset=0&resubmitflags=64&version=5.0.14.3&sortby=rank&sortdirection=descending&spell=on&hits=10&rpf_navigation:enabled=1&query=string(%22diabetes%22%2c+mode%3dsimpleany%2cannotation_class%3d%22user%22)&qtf_lemmatize=True";

Getopt::Long::Configure('bundling');
GetOptions
	("v"  => \$verbose, "verbose"  => \$verbose,
	"V"   => \$opt_V, "version"    => \$opt_V,
	"h"   => \$opt_h, "help"       => \$opt_h,
	"t=s" => \$opt_t, "timeout=s"  => \$opt_t,
	"w=s" => \$opt_w, "warning=s"  => \$opt_w,
	"c=s" => \$opt_c, "critical=s" => \$opt_c);

if ($opt_V) {
        print_revision($PROGNAME,'$Revision: 1.0 $');
        exit $ERRORS{'OK'};
}

if ($opt_h) {
        print_help();
        exit $ERRORS{'OK'};
}

($opt_w) || ($opt_w = shift) || ($opt_w = 10);
my $warn = $1 if ($opt_w =~ /^([0-9]+)$/);
($warn) || usage("Invalid warning threshold: $opt_w\n");

($opt_c) || ($opt_c = shift) || ($opt_c = 15);
my $crit = $1 if ($opt_c =~ /^([0-9]+)$/);
($crit) || usage("Invalid warning threshold: $opt_c\n");

($opt_t) && ($TIMEOUT = $opt_t);

($warn < $crit) || usage("Warning must be less than critical.\n");

$SIG{'ALRM'} = sub {
	print "CRITICAL FASTSEARCH: No response from fastsearch in $TIMEOUT seconds.\n";
	exit $ERRORS{'CRITICAL'};
};
alarm($TIMEOUT);

sub fast_search {
	my $found = undef;
	my $numresponses = 0;
	
	my $time1 = [gettimeofday];
	open CURL, "$CURL \"$URL\" 2>/dev/null | " or die "$!";
	while (<CURL>) {
		next unless /^#url /; # skip lines that don't match what we're looking for
		$found = ($_ =~ /^#url /) && ($numresponses++);
	}
	close CURL;
	my $time2 = [gettimeofday];
	my $interval = tv_interval $time1, $time2;
	my @responses = ($found, $numresponses, $interval);
	return @responses;
}

my @reply = fast_search;
if ($reply[0]) {
	# we got a reponse from fastsearch, so find out how long it took
	if ($reply[2] >= $crit || $reply[1] < 10) {
		print "CRITICAL FASTSEARCH: Got $reply[1] responses from fast in $reply[2] seconds.\n";
		exit $ERRORS{'CRITICAL'};
	} elsif ($reply[2] >= $warn && $reply[2] < $crit) {
		print "WARNING FASTSEARCH: Got $reply[1] responses from fast in $reply[2] seconds.\n";
		exit $ERRORS{'WARNING'};
	} else {
		print "OK FASTSEARCH: Got $reply[1] responses from fast in $reply[2] seconds.\n";
		exit $ERRORS{'OK'};
	}
}
# We got an unknown response
print "UNKNOWN FASTSEARCH: Unknown response from server.\n";
exit $ERRORS{'UNKNOWN'};
