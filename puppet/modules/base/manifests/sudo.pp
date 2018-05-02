class base::sudo (

) {

	$pre_bin = $operatingsystem ? {
		'FreeBSD'	=> '/usr',
		default		=> ''
	}

	$local_root = $operatingsystem ? {
		'FreeBSD'	=>	'/usr/local',
		default		=>	''
	}

	$rootgroup = $osfamily ? {
   		 'CentOS'  => 'root',
  		 'FreeBSD' => 'wheel',
  		  default  => 'root',
	}

	package { "sudo":
		ensure => installed
	}

	file {
		"${local_root}/etc/sudoers":
#		"/etc/sudoers":
			ensure	=> present,
			owner	=> 'root',
			#group	=> '($operatingsystem =~ /FreeBSD/ ? wheel : root)',
			group	=> $rootgroup, 
			mode	=> 0440,
			content	=> template("base/sudoers.erb");
	}
}
