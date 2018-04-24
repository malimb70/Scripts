#!/usr/bin/perl -w

use strict;
use Date::Calc ( ":all" );
use File::Copy;

# Today's date
my ( $yy, $mm, $dd ) = Today();
# Yesterday's date
my ( $yestYY, $yestMM, $yestDD ) = Add_Delta_Days( $yy, $mm, $dd, -1 );

# Ensure proper formatting of dates with leading 0
($mm < 10) && ($mm = "0" . $mm);
($dd < 10) && ($dd = "0" . $dd);
($yestMM < 10) && ($yestMM = "0" . $yestMM);
($yestDD < 10) && ($yestDD = "0" . $yestDD);

my $logDate = "$yy" . "$mm" . "$dd";
my $yestLogDate = "$yestYY" . "$yestMM" . "$yestDD";

print "log date = $logDate\n";
print "yesterday log date = $yestLogDate\n";

my @wte = ("usnjwweb15", "usnjwweb38", "usnjwweb39", "usnjwweb42");
my @eh = ("usnjwweb12", "usnjwweb30", "usnjwweb31", "usnjwweb34", "usnjwweb57");
my @ehp = ("usnjwweb47", "usnjwweb48", "usnjwweb49", "usnjwweb50", "usnjwweb51");
my @jm = ("usnjwweb36", "usnjwweb37", "usnjwweb40", "usnjwweb46");
my @sbd = ("usnjwweb23", "usnjwweb24", "usnjwweb25");

sub copyLogs ($$) {
	my $web = shift;
	my $app = shift;
	my $os = shift;

	my $logprefix = "";

	system("/bin/mount -t cifs -o username=wf_admin,password=Password12 //${web}/$app /mnt/$app/$web");

	if ($os eq "2008") {
		$logprefix = "u_ex";
	} elsif ($os eq "2003") {
		$logprefix = "ex";
	}
	$yestLogDate =~ s/^20//;
	print "Copy from /mnt/$app/$web/${logprefix}${yestLogDate}.log to /reports/$app/$web/";
	copy("/mnt/$app/$web/${logprefix}${yestLogDate}.log", "/reports/$app/$web/") or warn "Couldn't copy ${logprefix}${yestLogDate}.log: $!";
	print "...complete.\n";
	
	system("/bin/umount /mnt/$app/$web");
}

foreach my $server (@wte) {
	&copyLogs($server, "whattoexpect", "2008");
}
foreach my $server (@eh) {
	&copyLogs($server, "everydayhealth", "2003");
	&copyLogs($server, "eh_mobile", "2003");
}
foreach my $server (@ehp) {
	&copyLogs($server, "everydayhealth", "2008");
}
foreach my $server (@jm) {
	&copyLogs($server, "jillianmichaels", "2008");
}
foreach my $server (@sbd) {
	&copyLogs($server, "southbeachdiet", "2008");
}
