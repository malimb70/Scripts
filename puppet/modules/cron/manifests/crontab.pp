class cron::crontab{
$test="usnjqa1swtst01"
cron { crontab:
        command => "/root/testing.sh ",
        hour => '1',
        minute => '10',
        monthday => '*',
        month =>'*',
        weekday => '*',
    }
file {"/root/testing.sh":
        ensure=>file,
        owner=>'root',
        group=>'root',
        mode=>'755',
        source => "puppet:///modules/cron/$hostname/testing.sh";
        }

$msg = "Running cron on $hostname"
notice($test)
notify { $msg: }

#    file { "/etc/crontab":
#        owner => "root",
#        group => "root",
#        mode => 644,
#	source => 'puppet:///modules/cron/$hostname/crontab',
#    }
}
