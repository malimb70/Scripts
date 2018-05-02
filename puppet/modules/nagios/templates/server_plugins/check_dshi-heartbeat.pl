#!/usr/bin/perl
# If you have question or concerns regarding this script
# please contact schan@waterfrontmedia.com
# 
# Nagios Plugin for SOAP HEARTBEAT check
# Usage: $0 [URL]
# Below will be a soap heartbeat check on http://wfm01.wse.tx.dshisystems.com/txnet20wse/
# EXAMPLE: check_dshi-heartbeat.pl http://wfm01.wse.tx.dshisystems.com/txnet20wse/
#

use SOAP::Lite;
use Time::HiRes;

# Possible return codes (interpreted by Nagios)
%ERRORS = ('UNKNOWN' , '3',
           'OK' , '0',
           'WARNING', '1',
           'CRITICAL', '2');

$URI = 'http://dshisystems.com/'; # Service Identifier aka "namespace"
$PROXY = $ARGV[0]; # Server to contact that provides the methods
#$PROXY = 'http://wfm01.wse.tx.dshisystems.com/txnet20wse/'; # Server to contact that provides the methods

my $soap = SOAP::Lite
	-> uri($URI)
	-> proxy($PROXY);

$soap->transport->http_request->header('User-Agent'=>'MONITORING_CHECK');

# This variable holds the current time #
my $start = [ Time::HiRes::gettimeofday( ) ];

my $som = $soap->HEARTBEAT();

# Calculate total runtime (current time minus start time) #
my $elapsed = Time::HiRes::tv_interval( $start );
#print "Elapsed time: $elapsed seconds!\n";

$result = $som->valueof('//HEARTBEATResponse/HEARTBEATResult');

$state = "";
if ($elapsed > 0.75) {
	$state =  "WARNING";
	print "HEARTBEAT STATUS: " . $state . " - (slow SOAP request.) Time for query: $elapsed seconds.\n";
}
elsif ($elapsed > 2.00) {
	$state =  "CRITICAL";
        print "HEARTBEAT STATUS: " . $state . " - (very slow SOAP request.) Time for query: $elapsed seconds.\n";
}
elsif ($result eq "OK") {
	$state = "OK";
	print "HEARTBEAT STATUS: " . $state . " - Time for query: $elapsed seconds.\n";
}
elsif ($result ne "OK") {
	$state = "CRITICAL";
	print "HEARTBEAT STATUS: " . $state . " - Time for query: $elapsed seconds.\n";
}

exit $ERRORS{"$state"}
