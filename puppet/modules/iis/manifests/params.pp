class iis::params {
case $::operatingsystem {
      'windows' : {
		$ip_address=$::ipaddress
		}
	}
}
