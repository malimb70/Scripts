class eh-ssh::banner
{
	if ( $::operatingsystemrelease =~ /^7/) and ( $::hostname !~ /^usnjlvsftp03/) and ( $::hostname !~ /^awslftp01/) {
		file { '/etc/ssh/sshd_config' : source => "puppet:///modules/eh-ssh/sshd_config-centos7" }
		notify { "This is Centos 7 server without vsftp servers." : }
	}
	elsif ( $::operatingsystemrelease =~ /^6/) and ( $::hostname !~ /^usnjlvsftp03/) and ( $::hostname !~ /^awslftp01/)
	{
		file { '/etc/ssh/sshd_config' : source => "puppet:///modules/eh-ssh/sshd_config-centos6" }
		notify { "This is Centos 6 server without vsftp servers." : }
	}
	
    if ( $::operatingsystemrelease =~ /^7/ ) {
        $cmd="sed -ie 's/^#Banner .*$/Banner \/etc\/issue.net/g' /etc/ssh/sshd_config"
        $bfile="/etc/issue.net"
	    $scmd="/bin/systemctl reload sshd.service"
    }
    else
    {
        $cmd="sed -i 's/^#Banner .*$/Banner \/etc\/ssh\/sshd-banner/' /etc/ssh/sshd_config"
        $bfile="/etc/ssh/sshd-banner"
	    $scmd="/sbin/service sshd reload"
    }

    file { $bfile: source => "puppet:///modules/eh-ssh/sshd-banner" }

    exec {
        'addbannertossh':
            cwd => '/etc/ssh/',
            path   => "/usr/bin:/usr/sbin:/bin",
            subscribe => File[$bfile],
            refreshonly => true,
            command => $cmd;
        }

    service { "sshd":
        ensure => "running",
        enable    => true,
        require => Exec['addbannertossh']
    }

    exec 
	{
        'reload':
            command => $scmd,
            #onlyif = "test `grep '^#Banner' sshd_config |wc -l ` -ge 1",
            subscribe => File[$bfile],
            refreshonly => true,
            require => [Service['sshd'], Exec['addbannertossh']];
    }
}

