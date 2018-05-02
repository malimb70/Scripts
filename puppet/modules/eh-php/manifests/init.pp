class eh-php (
	$php_ver="5.6.11"
)
{

	package {
            [ 'mysql-devel', 'libxml2-static', 'libxml2-devel', 'libxml2'  ]:
               ensure => installed;
        }
	
#	file { "/usr/local/php-$php_ver":
#    	ensure => "directory",
 #   	owner  => "root",
 #   	group  => "root";
 #   }

    notify {"$php_ver": }

	exec { "php_symlink":
		path   => "/usr/bin:/usr/sbin:/bin",
        onlyif  => "/usr/bin/test ! -d /usr/local/php",
		require => Exec['compilePHP'],
        command => "ln -s /usr/local/php-$php_ver /usr/local/php ";
    }

	exec {
		'wgetPHPFile':
            cwd => '/usr/local/src',
            path   => "/usr/bin:/usr/sbin:/bin",
            onlyif => "/usr/bin/test ! -f /usr/local/php/php-$php_ver",
            command => "/usr/bin/wget -q http://php.net/get/php-$php_ver.tar.gz/from/this/mirror && mv /usr/local/src/mirror /usr/local/src/php-$php_ver.tar.gz";
    }


	exec {
		'untarPHPFile':
            cwd => '/usr/local/src',
            path   => "/usr/bin:/usr/sbin:/bin",
            require => Exec['wgetPHPFile'],
            onlyif => "/usr/bin/test ! -f /usr/local/php/php-$php_ver",
            command => "tar zxvf php-$php_ver.tar.gz";
    }
   
    exec {        
        'compilePHP':
     		cwd => "/usr/local/src/php-$php_ver",
            path   => "/usr/bin:/usr/sbin:/bin",
            onlyif => "/usr/bin/test ! -f /usr/local/php/php-$php_ver",
			notify => Service["httpd"],
            command => "sh configure --prefix=/usr/local/php-$php_ver --with-apxs2=/usr/local/httpd/bin/apxs --with-curl --with-mysql --with-zlib --enable-ftp  && make && make install && install -v -m644 php.ini-production /etc/php.ini && ln -snf /usr/local/php-$php_ver /usr/local/php && /bin/touch /usr/local/php/php-$php_ver";
    }
}
