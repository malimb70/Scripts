# http://github.com/camptocamp/puppet-nfs/blob/master/manifests/classes/base.pp
class nfs::base {

  package { "portmap":
    ensure => present,
  }

  case $operatingsystem {

    Ubuntu: {
      package { "nfs-common":
        ensure => present,
      }

#      service { "nfs-common":
#        ensure => running,
#        enable => true,
#        hasstatus => true,
#        require => Package["nfs-common"],
#      }

      service { "portmap":
        provider => debian,
        ensure => running,
        enable => true,
        hasstatus => false,
        require => Package["portmap"],
      }
    }

    RedHat, CentOS: {
      package { "nfs-utils":
        ensure => present,
      }

      service { "netfs":
        enable => true,
        require => [Service["portmap"], Service["nfslock"]],
      }

      service { ["portmap", "nfslock"]:
        ensure => running,
        enable => true,
        hasstatus => true,
        require => [Package["portmap"], Package["nfs-utils"]],
      }
    }

  }
}


