class base::nrpe (

	#http://files.nsclient.org/released/

) {

	include dynamic_vars

	case $::operatingsystem {
		FreeBSD: {
			$nsconfig = '/usr/local/etc/nrpe.cfg'
			$pkg_name = 'nrpe-ssl'
		}
		CentOS: {
			$nsconfig = '/etc/nagios/nrpe.cfg'
		#	$pkg_name = 'nagios-nrpe'
			case $::operatingsystemmajrelease {
			/^5/ :
				{
					$pkg_name = ['nagios-plugins-nrpe','nagios-plugins-all']
				}
			/^(6|7)/ :
				{
					$pkg_name = ['nrpe','nagios-plugins-all']
				}
			}
		}
		Windows: {
			$nsconfig = 'C:\Program Files\NSClient++\nsclient.ini'
			$pkg_name = 'NSClient++'
			$pkg_location = 'http://files.nsclient.org/legacy/NSCP-0.4.1.105-Win32.msi'
		}
	}

	if ($operatingsystem != 'Windows') {
		package {
			$pkg_name:
			ensure => installed
		}
	} else {
		package { # 4.1.105
			$pkg_name:
			ensure => installed,
			content => $pkg_location
		}
	}

	file {
		$nsconfig:
			ensure  => present,
			owner    => $admin_u,
			group   => $admin_g,
			mode    => 0600,
			#content => template("base/nrpe.cfg-${operatingsystem}-${architecture}.erb")
			content => multiple_templates("base/nrpe.cfg-${operatingsystem}-${architecture}.erb",
											"base/nrpe.cfg-${operatingsystem}.erb")
	}

}
