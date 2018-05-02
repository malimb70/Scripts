#!/usr/bin/perl -w




# 10/20/09      mdigiacomo       simple check of mysql threads taking longer than a given threashould in seconds 


use Getopt::Long;
use DBI;

use Date::Calc qw(Add_Delta_Days);




#
# Need to exclude all the connection from localhost,  or NULL
# Need to exclude those that for which state is sleep
# Need to check only for those where Command=Query 
# Just to avoid any problem exclude user "system user" (just in case)
#



my $debug = 0;


my ($host,$user,$pass,$crit)=@ARGV;
chomp($pass);



my %ERRORS = ('UNKNOWN' , '3',
           'OK' , '0',
           'WARNING', '1',
           'CRITICAL', '2');



my ($warning_flag, $critical_flag);
my ($day, $month, $year,$datestamp,$second,$minute,$hour, $HOME, $crit_thresh);
my ($s,$mi,$h,$d,$m,$y,$wday)=(localtime)[0,1,2,3,4,5,6];
$y=$y+1900;
$m++;
my $current_time = $h . $mi;



$datestamp = sprintf "%04d%02d%02d%02d%02d%02d", $y, $m, $d, $h, $mi, $s;
$HOME=$ENV{HOME};
$warning_flag =  $critical_flag = 0;


my $options = { 'host' => $host,  
                'port' => 3306 , 
                'socket' => '/db/data/mysql.sock',
                'crit' => $crit, 'warn' => 60, 
                'dbuser' => $user, 'dbpass' => $pass, 'email' => "prodnagios\@waterfrontmedia.com"};




my ($check_threads_dump_log_thresh_size, $filesize);
#$check_threads_log = "/var/tmp/check_threads_log";
$check_threads_dump_log = "/var/tmp/check_threads_dump_log";
$check_threads_dump_log_thresh_size = 10000000;
$crit_thresh = $options->{'crit'};
# $warn_thresh = $options->{'warn'};


 if ($filesize = -s $check_threads_dump_log) {
   if ($filesize >= $check_threads_dump_log_thresh_size ) {
     # Need to reset the file
     open DUMP_LOG,">$check_threads_dump_log" or die "$0 cannot open log file $check_threads_dump_log\n";
     close(DUMP_LOG);
     }
   } # end if



# Need to be able to check the show full processlist 





sub get_status {
  my ($options_ref) = @_;

  my($host,$port,$socket,$state);
  $host = $options->{'host'};
  $port = $options->{'port'};
  $socket = $options->{'socket'};


  # I will dump the lines in this file that have a time higher that the threshould 
  open (CHECK_LOG,">>$check_threads_dump_log");


        # Need to pass the mysql user  or extract it from the options

        if ($debug) {
          print STDOUT "----------------------------------------------------------\n";
          print STDOUT "get_status routine :: host=", $options_ref->{'host'}, ", " , $host , "\n";
          print STDOUT "get_status routine :: port=", $options_ref->{'port'}, ", " , $port , "\n";
          print STDOUT "get_status routine :: socket=", $options_ref->{'socket'}, " , " , $socket , "\n";
          print STDOUT "get_status routine :: user=", $options_ref->{'dbuser'}, "\n";
          print STDOUT "----------------------------------------------------------\n";
          }


	my $dbh = DBI->connect("DBI:mysql:host=$host;port=$port;mysql_socket=$socket", $options_ref->{'dbuser'}, $options_ref->{'dbpass'});
	if (not $dbh) {
                $state = "CRITICAL";
		print "MYSQL THREADS STATUS : " . $state . " - : cannot connect to $host";
                exit $ERRORS{"$state"};
	}

	my $sql = "show full processlist";
	my $sth = $dbh->prepare($sql);
	my $res = $sth->execute;

	if (not $res) {
                $state = "CRITICAL";
		print "MYSQL THREADS STATUS : " . $state . " - : no results from the query ";
                exit $ERRORS{"$state"};
	}


     my $count = 0;
     while ($ref = $sth->fetchrow_hashref) {
       # Need start inserting checks 

           if ( ($ref->{'Host'}) && ($ref->{'Host'} ne 'localhost') )  {
              if   ( ($ref->{'Command'}) && ($ref->{'Command'} eq 'Query'))   {
       
           # Need to check the value of Time
                if (($ref->{'Time'}) && ($ref->{'Time'} >= $crit_thresh ))   {
                  # We have found a row whose time is longer than threshould 

                   $critical_flag++;

                   print CHECK_LOG $datestamp, " $$ : --------------------------------------------------- \n"; 
                   print CHECK_LOG $datestamp, " $$ : ","CRITICAL : Found Statement with Time higher than $crit_thresh, please check. \n"; 
                   foreach my $kk (keys %$ref)  {
                     if ($ref->{$kk}) {
                       print CHECK_LOG $datestamp, " $$ :: \t" , $kk, " => ",  $ref->{$kk} , "\n";
                       }
                     else {
                       print CHECK_LOG $datestamp, " $$ :: \t" , $kk, " => ",  "NULL\n";
                       }
                    } # end foreach 

                   } # end if (($ref->{'Time'}) && ($ref->{'Time'} >= $crit_thresh ))  

                 } # end inner if
              } # end if 


       # Need end ending checks 
       $count++;
       } # end while

	$sth->finish;
	$dbh->disconnect;


   close(CHECK_LOG);



      # Need to check the flags for reports 


#
# At the moment not checking for warnings
#

      if ($critical_flag) {
        print STDOUT " FOUND $critical_flag rows with higher time than " ,  $crit_thresh , "\n";
        $state =  "CRITICAL";
        print "MYSQL THREADS STATUS " . $state . " - $critical_flag statements with higher time than ", $crit_thresh , "\n";
        }
      else {
        $state =  "OK";
        print "MYSQL THREADS STATUS " . $state . " - $critical_flag statements with higher time than ", $crit_thresh , "\n";
        }

exit $ERRORS{"$state"};

} # end 




get_status($options);

