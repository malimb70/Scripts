class base::resolv (
) {
        exec { 'unlock_resolv':
                command => 'chattr -i /etc/resolv.conf',
                path    => '/usr/local/bin/:/bin/:/usr/bin/',
        }

    file {
        "/etc/resolv.conf":
            ensure  => present,
            owner    => $admin_u,
            group   => $admin_g,
            mode    => 0644,
            require => Exec['unlock_resolv'],
            content => template("base/${operatingsystem}/resolv.conf.erb")
    }

        exec { 'lock_resolv':
                command => 'chattr +i /etc/resolv.conf',
                path    => '/usr/local/bin/:/bin/:/usr/bin/',
                require => File['/etc/resolv.conf'],
        }
}

