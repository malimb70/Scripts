#!/usr/bin/perl -w

use Getopt::Long;
use vars qw($opt_h $opt_s $opt_t $opt_c);
use Data::Dumper;
use strict;

sub print_usage {
	print "USAGE: \n";
}

GetOptions
(
	"h"   => \$opt_h, "help"	=> \$opt_h,
	"t"   => \$opt_t, "total"	=> \$opt_t,
	"c"   => \$opt_c, "current"	=> \$opt_c,
	"s=s" => \$opt_s, "statname=s"	=> \$opt_s
);

if ($opt_h) {
	print_usage();
	exit 0;
}

if (!defined $opt_s) {
	print "Must use -s to decide which stats you want to show.\n";
	exit 1;
}

if (( !defined $opt_t && !defined $opt_c ) or ( defined $opt_t && defined $opt_c )) {
        print "Must specify either -t or -c.\n";
        exit 1;
}

# declare some variables
my $requested;
my %curr = ();
my %tot = ();

# Parse some command line arguments
$opt_s && ($requested = $opt_s);

open(STAT, '/usr/local/bin/varnishstat -1 |') or die "$!";

while (<STAT>) {
#	next if /^LCK/;
#	next if /^SMA/;
	next if /^VBE/;
	my ($name, $total, $current, undef) = split;
	if ($current ne "\.") {
		$current = int($current + 0.5);
		$curr{$name} = $current;
	}
	$tot{$name} = $total;
}
close STAT;

my @get_these = split ",", $requested;
foreach my $s (@get_these) {
	print "$s:";
	$opt_t && (print $tot{$s});
	$opt_c && (print $curr{$s});
	print " ";
}
