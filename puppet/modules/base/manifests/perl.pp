class base::perl (

) {
	if ( operatingsystemmajrelease != "7" )
	{
	$perl_packages = [
		'perl-Date-Calc',
		'perl-Nagios-Plugin',
		'perl-XML-Simple',
		'perl-SOAP-Lite',
#		'perl-LWP-UserAgent-Determined',
		'perl-Time-HiRes'
	]
	
    package {
        $perl_packages:
			ensure => 'installed'
    }

	}
}
