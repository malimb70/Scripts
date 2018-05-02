# Installs packages required to utilize winbind for joining Active Directory
class winbind::install {
  case $::operatingsystemmajrelease {
    '5'     : {
      package { 'samba3x-winbind':
        ensure => latest,
      }
    }

    default : {
      $packages = ['samba', 'samba-winbind', 'samba-winbind-clients', 'oddjob-mkhomedir', 'krb5-workstation', 'krb5-libs', 'pam_krb5', 'krb5-devel']

      package { $packages:
        ensure => 'latest',
      }
    }

  }

}
