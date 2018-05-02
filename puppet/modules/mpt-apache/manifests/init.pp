class mpt-apache (
        $http_ver="2.4.16-1",
        $php_ver="5.6.10-1",
        $env="mpt"
) {


        file { "/usr/local/src/httpd-$http_ver.el6.x86_64.rpm":
                owner => root, group => root, mode => 775,
                source => "puppet:///modules/mpt-apache/httpd-$http_ver.el6.x86_64.rpm"
        }

        file { "/usr/local/src/php-$php_ver.el6.x86_64.rpm":
                owner => root, group => root, mode => 775,
                source => "puppet:///modules/mpt-apache/php-$php_ver.el6.x86_64.rpm"
        }

        notify { "$http_ver and $php_ver and $env": }

        exec { "apache-$http_ver-instalation":

                cwd => '/usr/local/src',
                path   => "/usr/bin:/usr/sbin:/bin",
                onlyif => "/usr/bin/test ! -f /usr/local/httpd/httpd-$http_ver",
                command => "rpm -ivh httpd-$http_ver.el6.x86_64.rpm; touch /usr/local/httpd/httpd-$http_ver"
                }

        exec { "php-$php_ver-instalation":

                cwd => '/usr/local/src',
                path   => "/usr/bin:/usr/sbin:/bin",
                onlyif => "/usr/bin/test ! -f /usr/local/php/php-$php_ver",
                command => "rpm -ivh php-5.6.10-1.el6.x86_64.rpm; touch /usr/local/php/php-$php_ver"
                }
        file { "/usr/local/httpd/modules/libphp5.so":
                owner => root, group => root, mode => 644,
        source => "puppet:///modules/mpt-apache/libphp5.so-$env",
        notify  => Service['httpd'],
        require => Exec["apache-$http_ver-instalation"];

                }
        file { "/usr/local/httpd/conf/httpd.conf":
                owner => root, group => root, mode => 644,
                source => "puppet:///modules/mpt-apache/httpd.conf-$env",
                notify  => Service['httpd'],
                require => Exec["apache-$http_ver-instalation"];
        }


        file { [ "/var/web", "/var/web/apibe.medpagetoday.com", "/var/web/api.medpagetoday.com", "/var/web/medforum.medpagetoday.com", "/var/web/mptadmin.medpagetoday.com", "/var/web/mptadminyii2.medpagetoday.com", "/var/web/www.medpagetoday.com","/var/web/api.medpagetoday.com/content/www","/var/web/mptadminyii2.medpagetoday.com/content/backend/web","/var/web/mptadminyii2.medpagetoday.com/content/backend", "/var/web/mptadminyii2.medpagetoday.com/content", "/var/web/api.medpagetoday.com/content" ]:
                ensure => "directory",
                owner  => "nobody",
                group  => "nobody",
                mode => 755
                }

        file { "/mnt/medpage_static-htmls" :
                ensure => "directory",
                owner  => "nobody",
                group  => "nobody",
                mode => 775
                }

        service { "httpd":
        ensure => "running",
        enable    => true,
        require => Exec["apache-$http_ver-instalation"]
    }

}

