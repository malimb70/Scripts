class dynamic_vars (

) {

#	$OS_version = $architecture =~ 64 ? '64' : '32';

	case $operatingsystem {
        FreeBSD: {
			$admin_u = 'root'
			$admin_g = 'wheel'
			$root_cfgdir = '/usr/local/etc'
        }
        CentOS: {
			$admin_u = 'root'
			$admin_g = 'root'
			$root_cfgdir = '/etc'
        }
        Windows: {
			$admin_u = 'Administrator'
			$admin_g = 'Administrator'
        }
	}
}
