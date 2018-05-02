#!/usr/bin/perl -w


# mdigiacomo

# get our hostname for the email
use Sys::Hostname;
use Date::Calc qw(Add_Delta_Days);
use Getopt::Std;
use DBI;



my ($target_host,$user,$password)=@ARGV;
chomp($password);


# important that we know our host name for recording stats otherwise 
# everything would be recorded as localhost. 
$hostname=hostname();
($hostname,undef)=split/\./,$hostname,2;	# presume hostname is x.bla where all we want is x





# where we collect stats
#$target_host='usnjldb03.waterfrontmedia.net';


$target_port=3306;
$target_db='forums';
#$mailuser="prodnagios\@waterfrontmedia.com"; 




# exit 0=0k, 1=warning, 2=error

my %ERRORS = ('UNKNOWN' , '3',
           'OK' , '0',
           'WARNING', '1',
           'CRITICAL', '2');


my ($previous_forums_row_count, $rowcount_found, $previous_count,$current_count);

$row_count_log="/var/tmp/forums_content_row_count_log";
$previous_forums_row_count="/var/tmp/previous_forums_content_row_count";

$rowcount_found = 1;
$previous_count = 0;
$current_count = 0;


if (! -s $previous_forums_row_count) {
   open(COUNT_FILE, ">$previous_forums_row_count");
   close(COUNT_FILE);
   $rowcount_found = 0;
   };






open LOG,">$row_count_log" or die "$0 cannot open log file $row_count_log\n";
select LOG;	# direct all output to the log
&do_log ("starting rowcount stats collection on $target_host");
$return_code=0;


my (@db,$subject,$mail_cmd);
$mail_cmd = q{/bin/mail}; 
$subject="generate_forums_rowcounts.pl $target_host";	# default email subject line
$HOME=$ENV{HOME};
my $state = "";


# connect to our input and output hosts 
$dbh=DBI->connect("DBI:mysql:database=$target_db;host=$target_host;port=$target_port", "$user", "$password");


if (!$dbh) {
  &do_log("The connection to mysqld server failed");
  $state = "CRITICAL";
  close(LOG);
  print STDOUT "FORUMS CONTENT STATS : " . $state . " - : cannot connect to $target_host\n";
  exit $ERRORS{"$state"};
  }



# get the db names on this server. 
$sth=$dbh->prepare("select count(*) from content");
if (!$sth) {
  &do_log("The statement prepare failed on $target_host");
  close(LOG);
  $state = "CRITICAL";
  print STDOUT "FORUMS CONTENT STATS : " . $state . " - : The statement prepare failed on $target_host\n";
  exit $ERRORS{"$state"};
  }

my $res = $sth->execute();
if (!$res) {
  &do_log("The statement execution failed on $target_host");
  close(LOG);
  $state = "CRITICAL";
  print STDOUT "FORUMS CONTENT STATS : " . $state . " - : The statement execution failed on $target_host\n";
  exit $ERRORS{"$state"};
  }



$x=0;
if (my @dat=$sth->fetchrow_array()) {
	chomp($dat[0]);
	$db[$x]=$dat[0];

        $current_count = $dat[0];
        if (!$rowcount_found ) {
            open(COUNT_FILE, ">$previous_forums_row_count");      
            print COUNT_FILE $dat[0], "\n";
            close(COUNT_FILE);
          $state = "CRITICAL";
          print STDOUT "FORUMS CONTENT STATS : " . $state . " - : count file was not found and it has been set on $target_host\n";
          exit $ERRORS{"$state"};
          } # end if

        else {
            open(COUNT_FILE, "$previous_forums_row_count");      
            while (<COUNT_FILE>) {
                    $previous_count=$_;
                    chomp($previous_count);
              } # end while

            close(COUNT_FILE);
           if ($current_count <= $previous_count) {

             &do_log("$subject current count $current_count  is not higher than  $previous_count, please investigate.");
             # Need to send out an email saying that the count is not increasing
     	     $subject="$subject current count $current_count  is not higher than  $previous_count, please investigate.";
             close(LOG);
             $state = "CRITICAL";
             print STDOUT "FORUMS CONTENT STATS : " . $state . " - : $subject on $target_host\n";
             exit $ERRORS{"$state"};
             }
           else {
             open(COUNT_FILE, ">$previous_forums_row_count");
             print COUNT_FILE $current_count, "\n";
             close(COUNT_FILE);
             close(LOG);
             $state = "OK";
             print STDOUT "FORUMS CONTENT STATS : " . $state . " - : table count is increasing on $target_host\n";
             exit $ERRORS{"$state"};
             }

          }


	$x++;
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
