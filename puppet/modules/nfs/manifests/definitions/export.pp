define nfs::export ($ensure=present,
                    $share,
                    $options="",
                    $guest) {


  if $options == "" {
    $content = "${share} ${guest}"
  } else {
    $content = "${share} ${guest}($options)"
  }

$exports = "/etc/exports"

  case $ensure {
    present: {
      exec { "add${share}":
        command => "/bin/echo '$content' >> $exports && /usr/sbin/exportfs -a",
        unless  => "/bin/grep ^${share} $exports > /dev/null 2>&1";
      }
    }
    absent: {
      exec { "del${share}":
        command => "perl -i -ne 'next if m,^$share\s+,; print' $exports && /usr/sbin/exportfs -a",
        onlyif  => "/bin/grep ^${share} $exports > /dev/null 2>&1";
      }
    }
  }

  
#  file {"$guest $share":
#    ensure => $ensure,
#    content => $content,
#    path => "/etc/exports",
 #   notify => Exec['reload_nfs_srv'],
 # }
}


