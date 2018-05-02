#Time zone spesific module (NB)
class timezone {
    package { "tzdata":
        ensure => installed
    }
}

class timezone::central inherits timezone {
    file { "/etc/localtime":
        require => Package["tzdata"],
        source => "file:///usr/share/zoneinfo/US/Central",
    }
}

class timezone::utc inherits timezone {
    file { "/etc/localtime":
        require => Package["tzdata"],
        source => "file:///usr/share/zoneinfo/UTC
",
    }
}
