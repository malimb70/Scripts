class base::hosts {
	if ($operatingsystem =~ /CentOS/) {
		
		exec {'unlockhost':
			cwd => '/root',
			path => '/usr/bin:/usr/sbin:/bin',
			command => "/usr/bin/chattr -i /etc/hosts";
		}
	
		file {
			"/etc/hosts":
			ensure  => file,
			owner   => root, group => root, mode => 644,
			require => Exec['unlockhost'], 
			content => template("base/hosts-${operatingsystem}.erb"),
		}
		
		exec {'lockhost':
			cwd => '/root',
			path => '/usr/bin:/usr/sbin:/bin',
			require => File['/etc/hosts'],
			command => "/usr/bin/chattr +i /etc/hosts";
		}
	}
}

