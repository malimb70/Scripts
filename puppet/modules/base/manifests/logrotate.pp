class base::logrotate (

) {

	package { "logrotate":
		ensure => installed
	}

	file {
		"${root_cfgdir}/logrotate.d":
			ensure	=> Directory,
			user	=> 'root',
			group	=> ($operatingsystem =~ /FreeBSD/ ? 'wheel' : 'root'),
			mode	=> 0755
	}

	file {
		"${root_cfgdir}/logrotate.conf":
			ensure	=> present,
			user	=> 'root',
			group	=> ($operatingsystem =~ /FreeBSD/ ? 'wheel' : 'root'),
			mode	=> 0644
	}

	cron {
		"log_rotate_cron":
			command => "/usr/local/sbin/logrotate ${root_cfgdir}/logrotate.conf > /dev/null",
			user    => root,
			hour    => '1',
			minute  => '0',
			require => Package["logrotate"],
	}
}
