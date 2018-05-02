#!/usr/bin/perl

#use XML::LibXML;
use XML::Simple;
#use Data::Dumper;

# Possible return codes (interpreted by Nagios)
%ERRORS = ('UNKNOWN' , '3',
           'OK' , '0',
           'WARNING', '1',
           'CRITICAL', '2');

# Command line arguments
$address = $ARGV[0]; # the server address
$folder = $ARGV[1]; # the folder to check
$minutes = $ARGV[2];  # how many minutes old the files are for the total counti
$warn = $ARGV[3];
$crit = $ARGV[4];

# Use curl to get web content, assign to a variable
$test = `curl "http://$address/nettools/services/newsletterqueuemonitor.asmx/GetCount?Folder=$folder&Thresholdminutes=$minutes" 2> /dev/null`;

# use xml parser on new variable
$ref = XMLin($test, ForceArray => 1, KeyAttr => []);

$size = $ref->{content};

$state = "";

# check file count:
# if count is over $warn, return critical value
# if count is over $crit, return critical value
# else pass that everything is okay
if ($size > $crit) {
        $state = "CRITICAL";
} elsif ($size > $warn) {
        $state = "WARNING";
} else {
        $state = "OK";
}



# Exit with return code
print "QUEUE SIZE " . $state . " (" . $size . " file(s) older than " . $minutes . "mins)";
exit $ERRORS{"$state"}
