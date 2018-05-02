class spacewalk  (
	$spacewalk_env = $::spacewalk::params::spacewalk_env,
    $spacewalk_chan_key= $::spacewalk::params::spacewalk_chan_key,
    $spacewalk_repo= $::spacewalk::params::spacewalk_repo,
    $epel_repo= $::spacewalk::params::epel_repo,
) inherits spacewalk::params
{
	if ( $::ehenv == 'prod' or $::ehenv == 'stage' or $::hostname =~ /^mptl/)
	{
		$spacewalk_fqdn = "usnjlswalk01.waterfrontmedia.net"
		$rpm_name ="rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm"
	}
	else
	{
		$spacewalk_fqdn = "usnjqa1lspace01.waterfrontmedia.net"
		$rpm_name ="qa1-rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm"
	}

	$packageList = ['rhn-client-tools','rhn-check', 'rhn-setup', 'm2crypto', 'yum-rhn-plugin', 'osad', 'rhncfg', 'rhncfg-actions', 'rhncfg-client','spacecmd']

	package { $packageList :
		ensure => latest,
		require => Exec['setupSpacewalkClientRepo','setupEPELInstall','removehttps'],
	}

	exec {'registerSpacewalk':
    	cwd => '/root',
    	path => '/usr/bin:/usr/sbin:/bin',
    	creates => '/etc/sysconfig/rhn/systemid',
    	require => [ Package[$packageList, 'rhn-org-trusted-ssl-cert'], Exec['setupSpacewalkClientRepo','setupEPELInstall'] ], 
    	command => "rhnreg_ks --serverUrl=http://$spacewalk_fqdn/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=$spacewalk_chan_key";
  	}

	exec {'setupSpacewalkClientRepo':
        cwd => '/etc/yum.repos.d',
        path   => "/usr/bin:/usr/sbin:/bin",
        creates => '/etc/yum.repos.d/spacewalk-client.repo',
        command => "rpm -U $spacewalk_repo";
    }
  
     exec {'removehttps':
        cwd => '/etc/yum.repos.d',
        path   => "/usr/bin:/usr/sbin:/bin",
        #creates => '/etc/yum.repos.d/epel.repo',
        require => Exec['setupEPELInstall'],
	   command => "sed -i -e 's/https/http/g' /etc/yum.repos.d/epel.repo";
    }
 
    package { 
        'epel-release-6':
	   ensure => "absent"
    }

    exec {'setupEPELInstall':
     	cwd => '/etc/yum.repos.d',
        path   => "/usr/bin:/usr/sbin:/bin",
        creates => '/etc/yum.repos.d/epel.repo',
	    require => Package['epel-release-6'],
        command => "rpm -Uvh $epel_repo";
    }
   
    file { "/tmp/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm": 
        source => "puppet:///modules/spacewalk/$rpm_name" 
    }
    
    package {
        'rhn-org-trusted-ssl-cert':
   		ensure => 'present',
		provider => 'rpm', 
   		source => "/tmp/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm";
    }

  	service { "osad":
    	ensure => "running",
    	enable    => true,
    	require => [ Package["osad"], Exec['registerSpacewalk'] ] 
  	}

  	file { "/etc/sysconfig/rhn/allowed-actions/script/run": 
	   require => Package[$packageList],
	   source => "puppet:///modules/spacewalk/run";
    }

  	exec {        
        'enableRHNActions':
     	cwd => '/etc/yum.repos.d',
        path   => "/usr/bin:/usr/sbin:/bin",
        require => Package["osad"],
        onlyif => "/usr/bin/test ! -f /etc/sysconfig/rhn/puppet-enabled",
        command => "rhn-actions-control --enable-all && touch /etc/sysconfig/rhn/puppet-enabled";
    }
}
