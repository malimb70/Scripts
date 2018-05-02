# OS specific class 
class base::os (

) {

    ## Disable IPv6 for CentOS Specific (NB) ##
    service { "ip6tables":
        enable => false,
        ensure => stopped,
    }

    augeas {"/etc/sysconfig/network":
        context => [ "/files/etc/sysconfig/network" ],
        changes => [ "set NETWORKING_IPV6 no" ],
        onlyif => "match alias[.='NETWORKING_IPV6'] size == 0",
    }

    augeas {"/etc/modprobe.conf":
        context => [ "/files/etc/modprobe.conf" ],
        changes => [ "set alias[last()+1] ipv6",
                     "set alias[last()]/modulename off",
                     "set alias[last()+1] net-pf-10", 
                     "set alias[last()]/modulename off" ],
        onlyif => "match alias[.='ipv6'] size == 0",
    }

    exec {"disable-ipv6":
        path => "/bin",
        command => "echo 'options ipv6 disable=1' > /etc/modprobe.d/disable-ipv6",
        logoutput => true,
        unless => "grep ipv6 /etc/modprobe.d/disable-ipv6 2>/dev/null";
    }
    ## end ##
  

    ## Configure kernel parameters (NB) ##
#    file {
#        "/etc/sysctl.conf":
#            ensure  => present,
#            owner   => root, group => root, mode => 444,
#            source  =>  "puppet:///modules/os/sysctl.conf";

#    }
    ## end ##

}

