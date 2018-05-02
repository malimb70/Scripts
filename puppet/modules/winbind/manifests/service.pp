# Controls the services related to winbind
class winbind::service {
  case $::osfamily {
    RedHat  : {
      if ($::operatingsystemmajrelease < 7) {
        service { 'messagebus':
          ensure => 'running',
          enable => true,
#          before => Service['oddjobd'],
        }

 #       service { 'oddjobd':
 #         ensure => 'running',
 #         enable => true,
 #       }

        service { 'winbind':
          ensure => 'running',
          enable => true,
        }

      } else {
        service { 'winbind':
          ensure => 'running',
          name   => 'winbind.service',
          enable => true,
        }

#        service { 'oddjobd':
#          ensure => 'running',
#          name   => 'oddjobd.service',
#          enable => true,
#        }

      } # end else
    } # end RedHat

    default : {
          
         service { 'messagebus':
          ensure => 'running',
          enable => true,
         }

         service { 'winbind':
          ensure => 'running',
          enable => true,
         }
    }

  } # end case
}
