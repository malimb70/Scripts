class eh-rsyslog 
(
$env='prod',
)
{
  $packageList = ['rsyslog']
  
  package { $packageList :
    ensure => present,
  }
  
  case $::operatingsystemmajrelease {
	/^6/ : {
		file { "/etc/rsyslog.conf": 
			ensure => present,
			mode   => 644,
			owner  => root,
			group  => root,
			content => template("eh-rsyslog/rsyslog.conf.erb"),
			notify => Service['rsyslog'];
		}
	}
	/^7/ : {
		file { "/etc/rsyslog.conf": 
			ensure => present,
			mode   => 644,
			owner  => root,
			group  => root,
			content => template("eh-rsyslog/rsyslog.conf-centos7.erb"),
			notify => Service['rsyslog'];
		}	
	}	
  }

  service { "rsyslog":
    ensure => "running",
    enable    => true,
    require => [ package['rsyslog']],
  }

	file { "/etc/rsyslog.d/logserver.conf": 
		ensure => present,
		mode   => 644,
		owner  => root,
		group  => root,
		content => template("eh-rsyslog/logserver.conf.erb"),
		notify => Service['rsyslog'];
	}	
}
