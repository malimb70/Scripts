class eh_domainjoin (
    $domain_pass= $::eh_domainjoin::params::password,
    $domain_user= $::eh_domainjoin::params::username,
)
inherits eh_domainjoin::params
{
	file { "/root/joiningDomain.sh":
	ensure => 'file',
      	mode   => '0660',
        source => "puppet:///modules/eh_domainjoin/joiningDomain.sh";
    }

#notify { "Domain user password is $domain_pass": }
    exec {'eh_domainjoin':
        cwd => '/root',
        path => '/usr/bin:/usr/sbin:/bin',
        creates => '/tmp/systemid',
	require => File["/root/joiningDomain.sh"],
        command => "/bin/sh /root/joiningDomain.sh $username $domain_pass";
    }
}
