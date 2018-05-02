# Sysctl module using augeas (NB)
#
# Use case example:
# include sysctl
#
# sysctl::conf { 
#
#  # prevent java heap swap
#  "vm.swappiness": value =>  0;
#
#  # increase max read/write buffer size that can be applied via setsockopt()
#  "net.core.rmem_max": value =>  16777216;
#  "net.core.wmem_max": value =>  16777216;
#
# }

class sysctl {

    # nested class/define
    define conf ( $value ) {

        # $name is provided by define invocation

        # guid of this entry
        $key = $name

        $context = "/files/etc/sysctl.conf"

        augeas { "sysctl_conf/$key":
            context => "$context",
            onlyif  => "get $key != $value",
            changes => "set $key $value",
            notify  => Exec["sysctl_cmd"],
        }
    } 

    file { "sysctl_conf":
        name => $operatingsystem ? {
        default => "/etc/sysctl.conf",
        },
    }
    exec { "sysctl_cmd":
        command => "sysctl -e -p",
        refreshonly => true,
        subscribe => File["sysctl_conf"],
    }

}
