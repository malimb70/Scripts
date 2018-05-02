class base::route 
{

if ($operatingsystem =~ /CentOS/) {

    file {
                "/etc/sysconfig/network-scripts/route-eth0":
                    ensure  => file,
                    owner   => root, group => root, mode => 644,
                    content => template("base/route-${operatingsystem}.erb"),
}

}


}
