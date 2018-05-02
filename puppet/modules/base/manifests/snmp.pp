class base::snmp (

) {

	# net-snmp \

	if ($operatingsystem =~ /CentOS/) {
		package {
			"net-snmp-libs":
				ensure => installed
		}
		package {
			"net-snmp":
				ensure => installed,
				require => Package["net-snmp-libs"]
		}
	} elsif ($operatingsystem =~ /FreeBSD/) { #BSD
		package {
			"net-snmp":
				ensure => installed
		}
	} else {
		# Windows installed via MiB
	}

	if ($operatingsystem =~ /CentOS/) {

		file {
			"/etc/snmp/snmpd.conf":
				ensure => present,
				owner => root,
				group => root,
				mode => 0633,
				content => template("base/snmpd.cfg-${operatingsystem}.erb"),
        }

		service {
			"snmpd" :
			  hasstatus => true,
			  enable    => true,
			  ensure    => running,
			  require   => Package["net-snmp"]
		}
	}

	#CONFIG
	#
}
