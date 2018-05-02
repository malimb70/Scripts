class mpt-apache::vhost {

        file { "/usr/local/httpd/conf/extra/eh_header.conf":
                ensure => file,
                owner   => root, group => root, mode => 755,
                content => template("mpt-apache/eh_header.erb"),
        }
        file {  '/usr/local/httpd/conf/extra':
                path => '/usr/local/httpd/conf/extra',
                owner   => root, group => root, mode => 755,
                ensure => directory,
                require => File['/usr/local/httpd/conf/httpd.conf'],
                source       => ['puppet:///modules/mpt-apache/mpt'],
                recurse => true,

        }
}
