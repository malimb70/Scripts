class base  {

	
	if ($operatingsystem !~ /Windows/) {
		include base::sudo
		include base::atop
		include base::nrpe
		include base::ntp
		include base::pkg
		include base::snmp
		include base::perl
		include base::hosts
#		include base::route

$command = 'alias facter="facter -p"'

exec {"facter":
        path => "/bin",
        command => "echo '$command' >> /root/.bashrc",
        logoutput => true,
        unless => "grep facter /root/.bashrc 2>/dev/null";
    }
	
	
		if ($operatingsystem =~ /FreeBSD/) {
			include base::logrotate

			file {
				"/etc/rc.conf":
					ensure  => present,
					user    => $admin_u,
					group   => $admin_g,
					mode    => 0644,
					content => multi_template(
						"base/rc.conf.${fqdn}.erb",
						"base/rc.conf.${operatingsystem}.erb",
						"base/rc.conf.erb"
					)
			}
		}
	}
}
