# Make sure we run CPU at the maximum speed
# $maxcpuspeed is the facter fact - it is 0 if the feature 
# is disabled in BIOS, positive number otherwise

class cpuspeed {

    if $maxcpuspeed > 0 {
        augeas { "/etc/sysconfig/cpuspeed":
                context => ["/files/etc/sysconfig/cpuspeed"],
                changes => ["set /files/etc/sysconfig/cpuspeed/MAX_SPEED $maxcpuspeed",
                            "set /files/etc/sysconfig/cpuspeed/MIN_SPEED $maxcpuspeed"],
                onlyif => "get /files/etc/sysconfig/cpuspeed/MAX_SPEED == ''";
        }

        file { "/etc/sysconfig/cpuspeed":
            mode => 0644,
            owner => root,
            group => root,
        }
    
        exec { "service cpuspeed restart":
            path => "/bin:/sbin:/usr/sbin",
            command => "/bin/sync && /etc/init.d/cpuspeed restart",
            refreshonly => true,
            subscribe => Augeas["/etc/sysconfig/cpuspeed"];
        }
    }
}
