import "*"

# Default monit class
class monit {


    case $operatingsystem {
        
        CentOS: {
          #Install the packages
          package {
            [ 'monit' ]:
               ensure => installed;
          }

         # Setup for monit
          file {
           # Create a directory for instance config
            '/etc/monit.d':
              owner => root, group => root, mode => 755,
              require => Package['monit'],
              ensure => directory;

            # Create/set permission on the rc file
            "/etc/monit.conf":
               ensure => present,
               source => "puppet:///modules/monit/monit.conf",
               owner => root, group => root, mode => 600,
               require => Package["monit"];

            '/etc/monit.d/puppet.conf':
               owner => root, group => root, mode => 444,
               source => 'puppet:///modules/monit/monit-cent-puppet.conf',
               require => Package['monit'],
               notify => Service['monit'];

          }

          service {
            'monit':
                enable => "true",
                ensure => "running",
                hasstatus => "true",
                hasrestart => "true",
                subscribe => File["/etc/monit.conf"],
                require => Package["monit"],
          }

        } #End CentOS

   } #End OS Case
        
}

