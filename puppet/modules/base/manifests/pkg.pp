class base::pkg (

) {

	if ($operatingsystem =~ /FreeBSD/) {
		$base_pkgs = ['curl','pcre','bash','vim-lite']
	}

	if ($operatingsystem =~ /CentOS/) {
	     if ( hostname =~ /ldb/ or hostname =~ /LDB/ ) {	
		$base_pkgs = ['telnet','libaio','traceroute','tcpdump','mlocate','sshpass','perl-DBD-mysql','perl-DBI','perl-CPAN','sendmail','ksh','zip','unzip','gzip','perl-ExtUtils-MakeMaker','perl-Config-Tinyl','perl-Log-Dispatch','perl-Parallel-ForkManager']
	     }
	     else
	     {
		$base_pkgs = ['telnet','traceroute','tcpdump','mlocate','sshpass']
	     }	
	}

	if ($base_pkgs) {
		package { $base_pkgs:
			ensure => installed
		}
	}
}
