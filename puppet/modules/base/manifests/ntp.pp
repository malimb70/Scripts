class base::ntp (

) {

	include dynamic_vars

	package {
		"ntp":
		ensure => installed
	}

	service {
		"ntpd" :
			hasstatus => true,
			enable    => true,
			ensure    => running,
			require   => Package["ntp"]
	}

	file {
		"/etc/ntp.conf":
			ensure  => present,
			owner    => $admin_u,
			group   => $admin_g,
			mode    => 0600,
			content => template("base/${operatingsystem}/ntp.conf.erb")
	}

	file {
		"/usr/local/bin/ntp_fix_drift":
			ensure  => present,
			owner    => $admin_u,
			group   => $admin_g,
			mode    => 0755,
			content => template( "base/ntp_fix_drift.erb" )
			
	}
	
}
