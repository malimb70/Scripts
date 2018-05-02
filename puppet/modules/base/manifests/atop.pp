class base::atop {

	include dynamic_vars

	package { 'atop':
		ensure => installed
	}

#####0 1 * * * /usr/local/etc/rc.d/atop rotate >/dev/null
	cron {
		"atop_rotate_cron":
			command => "/usr/bin/atop rotate >/dev/null",
			user    => root,
			hour    => '1',
			minute  => '0',
			require => Package["atop"],
	}

	service {
		"atop" :
		  hasstatus => true,
		  enable    => true,
		  ensure    => running,
		  require   => Package["atop"];
    }
}
