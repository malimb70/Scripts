class nagios::client (

) {

    $nagios_plugins = [
		'nagios-plugins',
		'nagios-plugins-nrpe',
        'nagios-plugins-nt',
        'nagios-plugins-http',
		'nagios-plugins-ping',
		'nagios-plugins-ntp',
		'nagios-plugins-smtp',
		'nagios-plugins-tcp',
		'nagios-plugins-mysql'
	]

    package {
        $nagios_plugins:
                        ensure => 'installed'
    }

    # individual scripts

}
