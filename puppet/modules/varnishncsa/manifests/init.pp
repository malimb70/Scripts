class varnishncsa
(
  $myhash,
)
{
	package { "logrotate":
		ensure => installed
	}

	if $operatingsystem =~ /CentOS/
	{
		file {
			"/etc/cron.daily/logrotate":
				ensure	=> present,
				owner  	=> 'root',
				group	=> 'root',
				source  => "puppet:///modules/varnishncsa/logrotate", 
				mode	=> 0700
		}
	}	
	define create_varnishncsa ($servicename,$hostfilter) 
	{	
		$logfile="varnishncsa_$servicename"
	
#		notify {"Service Name : $servicename and host filter : $hostfilter and  Log File $logfile ":}

		file {
			"/etc/logrotate.d/$logfile":
				ensure	=> present,
				owner  	=> 'root',
				group	=> 'root',
				content => template("varnishncsa/varnishncsa_logrotate.erb"),
				mode	=> 0644
		}

		file {
			"/etc/init.d/$logfile":
				ensure	=> present,
				owner  	=> 'root',
				group	=> 'root',
				content => template("varnishncsa/varnishncsa_init.erb"),
				mode	=> 0755
		}

		service { "$logfile":
			ensure => running,
			enable => true,
		}	
	}
	create_resources(create_varnishncsa, $myhash)	
}

