#!/usr/bin/perl

use strict;

my $filer = $ARGV[0];

#print $filer; 
my $warn = $ARGV[1];
my $crit = $ARGV[2];
#print "warn: $warn";
#print "crit: $crit";
 
if ($crit == undef )
{
	print "Usage: check_san_mem.pl [filer] [warning threashold] [critical threashold]\n";
	print "\tEX. check_san_mem.pl usnjnsan02 20 50\n";
	exit (-3);
}

my $check_cmd = '/usr/bin/rsh '.$filer.' "priv set diag;mbstat" 2>&1';

#print $check_cmd;

my @cmd_results=`$check_cmd`;

#print @cmd_results;

my $tot_drops=0;


for (@cmd_results)
{
        #print $_;
        if ( $_ =~ m/[^,]\smalloc/)
        {
                #print $_;
                my @parsed_line = split(' ',$_);
                #print @parsed_line;
                my $int_drops = $parsed_line[9];
                #print $int_drops;
                if ($int_drops != 0) #last Char not zero
                {
                        $tot_drops += $int_drops;
                }
        }
}


if ($tot_drops >= $crit)
{
	print "CRITICAL\n Total malloc drops $tot_drops\n";
	exit (-2);
}
elsif ($tot_drops >= $warn )
{
	print "WARNING\n Total malloc drops $tot_drops\n";
        exit (-1);

}
else
{
        print "OK\n Total malloc drops $tot_drops\n";
        exit (0);

}

exit(0);


