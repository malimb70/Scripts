#!/usr/bin/perl

use strict;
use IO::File;

my $v_error_dir = '/var/log/varnish/fetcherror/';
my $pidfile = "$v_error_dir/varnish_fetcherror.pid";

if (! -e "$pidfile") {
    my ($pid) = fork();

    if ($pid) { ## Inside the mother process:
        my ($pf) = new IO::File($pidfile, O_CREAT | O_WRONLY, 0644) || die("UNABLE TO CREATE PID: $!\n");
        $pf->print($pid . "\n");
        $pf->close();
        exit(0);
    }

	sleep 2; #delay the getpid because memory is faster than IO - the box might be busy doing something else

	my ($pid_from_file) = `cat $pidfile`;
		chomp ($pid_from_file);
		
	print "Starting daemon... (PID: $pid_from_file)\n";
} else {
	if (-e "$pidfile") {
		die ("PIDFILE '$pidfile' exists - please check ps and remove file before restarting...\n");
	} else {
		die ("Failed to start - check permissions (user: " . getpwuid($<). ")\n");
	}
}

my $vlog_pid = open (VARNISHLOGH, "/usr/local/bin/varnishlog -c -m FetchError:backend|") or die ("Unable to open pipe to varnishlog: $!\n");

$SIG{'TERM'} = sub {
	kill ('SIGKILL', $vlog_pid); # make sure the tail ends
	unlink ($pidfile); # cleanup pid
	print "Exiting clean...\n";
	exit;
};

print "Starting varnishlog check: $vlog_pid\n";

select((select(VARNISHLOGH), $| = 1)[0]); #unbuffer to avoid memory leaching

my $lastid = '';

while (<VARNISHLOGH>) {
	chomp ($_);

	my ($id, $tag, $c, $data) = $_ =~ /\s*(\d+)\s+(\S+)\s+c\s+(.*)/i;

	if ($lastid != $id) {
		#new entry
		my $t = time();
		rename("$v_error_dir/fetcherror-$lastid", "$v_error_dir/fetcherror-$lastid-$t");

		$lastid = $id;
	}

	open (FETCHERRORH, ">> $v_error_dir/fetcherror-$id");
		print FETCHERRORH "$_\n";
	close (FETCHERRORH);
}

close (VARNISHLOGH);

#  178 SessionOpen  c 66.87.97.87 20027 10.133.104.169:80
#  178 ReqStart     c 66.87.97.87 20027 319167920
#  178 RxRequest    c POST
#  178 RxURL        c /iphone/getArticleRelDates2.cfm
#  178 RxProtocol   c HTTP/1.1
#  178 RxHeader     c Accept: */*
#  178 RxHeader     c Content-Type: application/x-www-form-urlencoded
#  178 RxHeader     c Cookie: CFID=25886763; CFTOKEN=118d12753feb4269-969B5990-CE6E-B017-08F5824CD4905B07; ISCMEUSER=false
#  178 RxHeader     c Accept-Language: en-us
#  178 RxHeader     c Content-Length: 492
#  178 RxHeader     c Accept-Encoding: gzip, deflate
#  178 RxHeader     c User-Agent: MedPage/4.7.5 CFNetwork/711.2.23 Darwin/14.0.0
#  178 RxHeader     c Host: www.medpagetoday.com
#  178 RxHeader     c Cache-Control: max-age=43200
#  178 RxHeader     c Connection: keep-alive
#  178 VCL_call     c recv pass
#  178 VCL_call     c hash
#  178 Hash         c /iphone/getArticleRelDates2.cfm
#  178 Hash         c www.medpagetoday.com
#  178 Hash         c desktop
#  178 VCL_return   c hash
#  178 VCL_call     c pass pass
#  178 Backend      c 274 mpt_dir MPT_44
#  178 FetchError   c backend write error: 35 (Resource temporarily unavailable)
#  178 Backend      c 33 mpt_dir MPT_44
#  178 FetchError   c backend write error: 35 (Resource temporarily unavailable)
#  178 VCL_call     c error deliver
#  178 VCL_call     c deliver deliver
#  178 TxProtocol   c HTTP/1.1
#  178 TxStatus     c 503
#  178 TxResponse   c Service Unavailable
#  178 TxHeader     c Server: Varnish
#  178 TxHeader     c Content-Length: 1072
#  178 TxHeader     c Accept-Ranges: bytes
#  178 TxHeader     c Date: Wed, 27 May 2015 18:21:03 GMT
#  178 TxHeader     c X-Varnish: 319167920
#  178 TxHeader     c Age: 10
#  178 TxHeader     c Via: 1.1 varnish
#  178 TxHeader     c Connection: close
#  178 TxHeader     c X-Cache: MISS
#  178 Length       c 1072
#  178 ReqEnd       c 319167920 1432750853.794509172 1432750863.796734333 0.000070095 10.002189636 0.000035524
