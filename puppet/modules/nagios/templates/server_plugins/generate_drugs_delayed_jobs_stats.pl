#!/usr/bin/perl -w


# mdigiacomo 10/11/2010



# get our hostname for the email
use Sys::Hostname;
use Date::Calc qw(Add_Delta_Days);
use Getopt::Std;
use DBI;



my ($debug) = 0;


my ($target_host,$user,$password)=@ARGV;




if ($debug) {
   open(TEST,">> /tmp/test1");
   print TEST "=======================================\n";
   print TEST "BEGINNING :: target_host===", $target_host, "===\n";
   print TEST "BEGINNING :: user===", $user, "===\n";
   print TEST "BEGINNING :: password===", $password, "===\n";
   print TEST "=======================================\n";
   close(TEST);
  } # end if ($debug)




chomp($password);


# important that we know our host name for recording stats otherwise 
# everything would be recorded as localhost. 
$hostname=hostname();
($hostname,undef)=split/\./,$hostname,2;	# presume hostname is x.bla where all we want is x







# where we collect stats
#$target_host='usnjldb03.waterfrontmedia.net';


$target_port=3306;
$target_db='wl_conditions_treatments';
#$mailuser="prodnagios\@everydayhealthinc.com"; 



my ($previous_forums_row_count, $rowcount_found, $previous_count,$current_count,$error_thresh,$warning_thresh,$table_name);
# $row_count_log="/var/tmp/drugs_delayed_jobs_row_count_log";

# This has been commented temporary
# $error_thresh = 20;

$error_thresh = 120;


$warning_thresh = 15;

$table_name = q{delayed_jobs};
#
# Check every 15 minutes.
# Error if > 20 rows in table.
# Warning if >5 rows in table.
# Normal if <=5 rows in table.
#



# exit 0=0k, 1=warning, 2=error

my %ERRORS = ('UNKNOWN' , '3',
           'OK' , '0',
           'WARNING', '1',
           'CRITICAL', '2');



$return_code=0;


my (@db,$subject,$mail_cmd);
$mail_cmd = q{/bin/mail}; 
$subject="generate_drugs_delayed_jobs_stats.pl $target_host";	# default email subject line
$HOME=$ENV{HOME};
my $state = "";






if ($debug) {
   open(TEST,">> /tmp/test1");
   print TEST "=======================================\n";
   print TEST "database====", $target_db, "===\n";
   print TEST "host====", $target_host, "===\n";
   print TEST "port====", $target_port, "===\n";
   print TEST "user====", $user, "===\n";
   print TEST "password====", $password, "===\n";
   close(TEST);
   }







# connect to our input and output hosts 
$dbh=DBI->connect("DBI:mysql:database=$target_db;host=$target_host;port=$target_port", "$user", "$password");


if (!$dbh) {
  $state = "CRITICAL";
  print STDOUT "DRUGS DELAYED JOBS STATS : " . $state . " - : cannot connect to $target_host\n";
  exit $ERRORS{"$state"};
  }





if ($debug) {
   open(TEST,">> /tmp/test1");
   print TEST "=======================================\n";
   print TEST "after connection .... successfull  ====", $dbh, "===\n";
   close(TEST);
   }







# get the db names on this server. 
$sth=$dbh->prepare("select count(*) from $table_name");
if (!$sth) {
  $state = "CRITICAL";
  print STDOUT "DRUGS DELAYED JOBS STATS : " . $state . " - : The statement prepare failed on $target_host\n";
  exit $ERRORS{"$state"};
  }

my $res = $sth->execute();
if (!$res) {
  $state = "CRITICAL";
  print STDOUT "DRUGS DELAYED JOBS STATS : " . $state . " - : The statement execution failed on $target_host\n";
  exit $ERRORS{"$state"};
  }



$x=0;
if (my @dat=$sth->fetchrow_array()) {
	chomp($dat[0]);
	$db[$x]=$dat[0];
        $current_count = $dat[0];
        #
        # # Error if > 20 rows in table.
        # Warning if >5 rows in table.
        # Normal if <=5 rows in table.
        #

        if ($current_count > $error_thresh )  {
          $state = "CRITICAL";
          print STDOUT "DRUGS DELAYED JOBS STATS : " . $state . " - : The number of rows on the $table_name on $target_host is $current_count which is higher than $error_thresh\n";
          exit $ERRORS{"$state"};
          # This should generate an error
          }
        elsif  ( ( $current_count < $error_thresh ) &&  ($current_count > $warning_thresh) ) {
          $state = "WARNING";
          print STDOUT "DRUGS DELAYED JOBS STATS : " . $state . " - : The number of rows on the $table_name on $target_host is $current_count which is higher than $warning_thresh \n";
          exit $ERRORS{"$state"};
          }
        else {
          $state = "OK";
          print STDOUT "DRUGS DELAYED JOBS STATS : " . $state . " - : The number of rows on the $table_name on $target_host is $current_count\n";
          exit $ERRORS{"$state"};
          }

} # end if 


exit(0);






sub do_log {
        my ($s,$mi,$h,$d,$m,$y)=(localtime)[0,1,2,3,4,5];
        my $logline;
        $y=$y+1900;
        $m++;
        $logline=sprintf "%04d/%02d/%02d %02d:%02d:%02d $_[0]\n ",$y,$m,$d,$h,$mi,$s;
        print $logline;
        return;
}

sub usage {
    print << "EOF";

    This program gets approximate rowcount statistics for all databases on the source host and stores
    them in svc1-was.is.waterfrontmedia.com.table_rowcounts.rowcounts.
    Only tables having more than minrows rows are included. 
    The local user on this host to get the statistics is rowcounts by default. This user 
    is also used on svc1-was.is.waterfrontmedia.com to insert the row counts. 
    The rowcounts are gathered using show table status and not select count(*) so there is 
    some inaccuracy. 
    This script also automatically prunes old statistics which are older than two years. 

    usage: $0 [-option -option ....] option list below:

     -h        : this (help) message
     -u        : mysql user. $HOME/.user must contain pw.  default=rowcounts
     -s        : hostname for generating table rowcounts. default=localhost
     -p        : port for mysql. default=3306
     -e        : dbs to exclude. default=test,lost+found,mysql,information_schema. if used, you must specify include even these
			takes precedence over include. comma list, no spaces. 
     -i        : dbs to include. only these will be examined. no default. comma list, no spaces.
     -m        : email to send output to. default=prodnagios\@waterfrontmedia.com  
     -q        : do not send mail if no error. has no default; if not present mail is always sent
     -n        : default minimum rows to capture; if < n no capture done. default 1000

EOF
	$return_code=1;
        exit $return_code;
    }
