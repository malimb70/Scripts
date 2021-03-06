#!/usr/bin/perl
# Copyright 2008 by Ingo Lantschner (ingo@boxbe.com)
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version. See <http://www.gnu.org/licenses/>.

require 5.6.1;
use lib "/usr/local/lib/perl/NetApp";  
use NaServer;
use NaElement;
use Nagios::Plugin;
use strict;
use warnings;

use vars qw($VERSION $PROGNAME $verbose $warn $critical $timeout $result);
$VERSION = "0.5 ALPHA_NagKonf"; # mit konformen Parametern und Perfdata/Timeout

use File::Basename;
$PROGNAME = basename($0);

my $p = Nagios::Plugin->new(
    usage => "Usage: %s [-v|--verbose] [-H <filer>] [-t <timeout>]",
    version => $VERSION,
    blurb => 'This plugin checks the free space on NetApp filers.', 
	license => "Copyright 2008 by Ingo Lantschner\nAuthor: Ingo Lantschner",
	url => 'http://ingo.lantschner.name/',
	extra => "\nThis plugin checks the free space on volumes.

    Consider using -v(vv) for debugging, if you dont get what you expect. 
",
  
);

# Define and document the valid command line options
# usage, help, version, timeout and verbose are defined by default.

$p->add_arg(
	spec => 'host|H=s',
	required => 1,
	help => 
qq{IP-address or hostname of the filer.},
);

$p->add_arg(
	spec => 'username|u=s',
	required => 0,
	default => 'nagios',
	help => 
qq{Username for login to the filer. Defaults to nagios},
);

$p->add_arg(
	spec => 'password|p=s',
	help => 
qq{Password of the user, no default ;-)},
);

$p->add_arg(
	spec => 'volume|v=s',
	help =>
qq{Volume name to check},
);

$p->add_arg(
	spec => 'warning|w=i',
	default => 70,
	help => 
qq{Threshold for warnings in %, defaults to 70},
);

$p->add_arg(
	spec => 'critical|c=i',
	default => 90,
	help => 
qq{Threshold for critical in %, defaults to 90},
);

# Parse arguments and process standard ones (e.g. usage, help, version)
$p->getopts;
my $debug = $p->opts->verbose;

# Thresholds prC<fen
foreach ($p->opts->warning, $p->opts->critical) {
	if ($_ < 0 or $_ > 100) {
		$p->nagios_die( "ERROR: Thresholds are in % and range from 0 to 100!" );
	}
}

# Thresholds setzen
$p->set_thresholds(
	warning => $p->opts->warning,
	critical => $p->opts->critical
); 

## Timeout START (Hinweis: Nicht kompatibel mit sleep!) ---------------
##

my $timeout = $p->opts->timeout;
print "Timeout: $timeout\n" if $debug > 1;
 
$SIG{ALRM} = sub {
	$p->nagios_die("ERROR: Timeout ($timeout s) reached");
};
alarm $timeout;
## Ende Timeout START (Timer wird gestopt mt alarm(0) weiter unten) ---

my $filer = $p->opts->host;
my $major_version = 1;
my $minor_version = 3;
my $user = $p->opts->username;
my $pass = $p->opts->password;
my $volume = $p->opts->volume;

my $exit = { 	ok 		=> 0,
				warn 	=> 1,
				crit	=> 2,
				unknow	=> 3,
				};
my $out;

# Schritt 1: Servercontext erzeugen
my $s = NaServer->new ($filer, $major_version, $minor_version);

# Schritt 2: Sessionparameter setzen
check_out($s->set_transport_type("HTTP"));
check_out($s->set_style("LOGIN_PASSWORD"));
check_out($s->set_admin_user($user, $pass));

# Schritt 3: Sende Komando an die Core API des Filers
$out = $s->invoke( "volume-list-info");
print Dumper($out) if $debug > 2;

if ($out->results_status() eq "failed"){
	my $r = $out->results_reason();
    $p->nagios_die( "ERROR invoking volume: $r" );
}

my $volume_info = $out->child_get("volumes");

my @result = $volume_info->children_get();

# Variablen fC<r die Ermittlung des Maximalwertes
my $max_result = 0;
my $max_auslastung = 0;
my $max_volname ;
my $belegtGB = 0;
my $totalGB = 0;

if (defined $volume) {
	foreach my $vol (@result) {
		my $vol_name = $vol->child_get_string("name");
		if ($vol_name eq $volume) {
			my $size_total = $vol->child_get_int("size-total");
			my $size_used = $vol->child_get_int("size-used");
			my $belegtPrzt = $vol->child_get_int("percentage-used");
			$belegtGB = $size_used / 1024 / 1024 / 1024;
			$totalGB = $size_total / 1024 / 1024 / 1024;
			if ($belegtPrzt > $max_auslastung) {
				$max_auslastung = $belegtPrzt;
				$max_volname = $vol_name;
			}
			$p->add_perfdata(
				label   => "$vol_name",
				value   => $belegtPrzt,
				uom             => "%",
				threshold       => $p->threshold(),
			);
			$result = $p->check_threshold($belegtPrzt);
			print "Nagios-result: $result \n" if $debug > 0;
			if ($result == 3) {
				$p->nagios_die("Unknown result for $belegtPrzt. Plugin exits now.");
			}
			$max_result = $result;
		}
	}
} else {
	foreach my $vol (@result){
		my $vol_name = $vol->child_get_string("name");
		print  "Volume/Aggr name: $vol_name \n" if $debug > 0;
		my $size_total = $vol->child_get_int("size-total");
		print  "Total Size: $size_total bytes \n" if $debug > 0;
		my $size_used = $vol->child_get_int("size-used");
		print  "Used Size: $size_used bytes \n" if $debug > 0;
		my $belegtPrzt = $vol->child_get_int("percentage-used");
		print  "Used Size: $belegtPrzt % \n" if $debug > 0;
		# Auslastung berechnen
		$belegtGB = $size_used / 1024 / 1024 / 1024;
		$totalGB = $size_total / 1024 / 1024 / 1024;
		if ($belegtPrzt > $max_auslastung) { 
			$max_auslastung = $belegtPrzt;
			$max_volname = $vol_name;
		}
		$p->add_perfdata(
			label	=> "$vol_name",
			value	=> $belegtPrzt,
			uom		=> "%",
			threshold	=> $p->threshold(),
		);
		$result = $p->check_threshold($belegtPrzt);
		print "Nagios-result: $result \n" if $debug > 0;
		if ($result == 3) {p->nagios_die("Unknown result for $belegtPrzt. Plugin exits now.")} 
		if ($result > $max_result) { $max_result = $result}
	
	
	}
}

my $max_auslastung_gerundet = sprintf "%.2f", "$max_auslastung";
$belegtGB = sprintf "%.2f", "$belegtGB";
$totalGB = sprintf "%.2f", "$totalGB";

$p->nagios_exit(
     return_code => $max_result,
     message => "Volume $max_volname - $belegtGB Gb used out of $totalGB Gb (${max_auslastung_gerundet}%)"
);
alarm(0);  # Beendet Timeout (alarm ...)

# Subroutine um Fehler bei Verwendung der NaServer Class Methoden abzufangen
sub check_out {
	my $out = $_[0];
	if (ref ($out) eq "NaElement") {
		if ($out->results_errno != 0) {
			my $r = $out->results_reason();
			$p->nagios_die("ERROR: $r");
		}
	}
}
