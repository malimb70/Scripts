class sendmail 
(
$env='prod',
)
{
  $packageList = ['sendmail','sendmail-cf', 'make', 'm4']
  
  package { $packageList :
    ensure => present,
  }

  service { "postfix":
    ensure => "stopped",
	enable    => false,
    require => Exec['makeConfig'],
  }  
  
  service { "sendmail":
    ensure => "running",
    enable    => true,
    require => [ Exec['makeConfig'], service['postfix'] ],
  }

  file { "/etc/mail/sendmail.mc": 
    ensure => present,
    mode   => 644,
    owner  => root,
    group  => root,
    content => template("sendmail/sendmail.mc.erb"),
    notify => Service['sendmail'];
  }

  exec {
    'makeConfig':
      cwd => '/etc/mail/',
      path   => "/usr/bin:/usr/sbin:/bin",
      require => [ Package['sendmail','sendmail-cf'], File['/etc/mail/sendmail.mc'] ],
      onlyif => "/usr/bin/test ! -f /etc/mail/latest",
      command => "m4 sendmail.mc > sendmail.cf && touch /etc/mail/latest";
    }
}
