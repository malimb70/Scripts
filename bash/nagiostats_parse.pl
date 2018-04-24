#!/usr/bin/perl

# purpose: parses nagiostats data and presents in Cacti format

use strict;

# nagios binary and configuration locations
my %nagiostat = ( 'bin' => '/usr/bin/nagiostats',
                  'cfg' => '/etc/nagios/nagios.cfg');

# verify binary and configuration locations
foreach my $i (keys %nagiostat) {
  if ( ! -e $nagiostat{$i}) {
    die "Specified Nagios binary and/or configuration files does not exist!\n";
  }
}

# accepted commands and headers for information returned
my %graphs = ( 'SVCLATENCY'   => ['AVGACTSVCLAT', 'AVGACTSVCEXT'],
                'SVCCHANGE'    => ['AVGACTSVCPSC', 'AVGPSVSVCPSC'],
                'HOSTLATENCY'  => ['AVGACTHSTLAT' ,'AVGACTHSTEXT'],
                'HOSTCHANGE'   => ['AVGACTHSTPSC' ,'AVGPSVHSTPSC'],
                'ACTCHECKS'    => ['NUMHSTACTCHK5M', 'NUMSVCACTCHK5M'],
                'PASSCHECKS'   => ['NUMHSTPSVCHK5M', 'NUMSVCPSVCHK5M'],
                'CMDBUFFERS'   => ['TOTCMDBUF', 'USEDCMDBUF'],
                'CACHEDCHECKS' => ['NUMCACHEDHSTCHECKS5M' ,'NUMCACHEDSVCCHECKS5M'],
                'EXTCMDS'      => ['NUMEXTCMDS5M'],
                'SVCCOUNT'     => ['NUMSERVICES', 'NUMSVCOK', 'NUMSVCWARN', 'NUMSVCUNKN', 'NUMSVCCRIT'],
                'HOSTCOUNT'    => ['NUMHOSTS', 'NUMHSTUP', 'NUMHSTDOWN', 'NUMHSTUNR'],
                'PARALLEL'     => ['NUMPARHSTCHECKS5M' ,'NUMSERHSTCHECKS5M']
 );

if (! defined($graphs{$ARGV[0]})) {
  die "Usage info here\n";
}

# construct parameters for command line
my $params;
foreach my $i (@{$graphs{$ARGV[0]}}) {
  if (! defined($params)) {
    $params = $i;
  }
  else {
    $params = $params . ",$i";
  }
}

# execute command and collect results
open(RESULTS, "$nagiostat{bin} -d $params -m|") or die "$!";
  
my $index=0;
while (<RESULTS>) {
  chomp;
  print "$graphs{$ARGV[0]}[$index]:$_ ";
  $index++;
}
print "\n";

close RESULTS;
