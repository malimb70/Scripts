class eh-apache (
	$http_ver="2.4.111",
	$pcre_ver="8.34-2"
)
{
	file { [ "/usr/local/apr" , "/usr/local/pcre" , "/usr/local/httpd" ]:
    	ensure => "directory",
    	owner  => "root",
    	group  => "root",
    }

    notify {"$http_ver and $pcre_ver": }

	exec {
		'wgetPCREFile':
            cwd => '/usr/local/src',
            path   => "/usr/bin:/usr/sbin:/bin",
            onlyif => "/usr/bin/test ! -f /usr/local/pcre/pcre-$pcre_ver",
            command => "/usr/bin/wget -q http://sourceforge.net/projects/pcre/files/pcre/$pcre_ver/pcre-$pcre_ver.tar.gz/download && mv /usr/local/src/download /usr/local/src/pcre-$pcre_ver.tar.gz && /usr/bin/wget http://apache.arvixe.com/httpd/httpd-$http_ver.tar.gz && /usr/bin/wget -q http://apache.arvixe.com/httpd/httpd-$http_ver-deps.tar.gz";
    }

	$packageList = ['gcc-c++.x86_64','zlib','zlib-devel']

	package { $packageList :
		ensure => present,
	#	require => Exec['untarPCREFile','compilePCRE'],
	}

	exec {
		"untarPCREFile":
            cwd => '/usr/local/src',
            path   => "/usr/bin:/usr/sbin:/bin",
            require => Exec['wgetPCREFile'],
            onlyif => "/usr/bin/test ! -f /usr/local/pcre/pcre-$pcre_ver",
            command => "tar zxvf pcre-$pcre_ver.tar.gz && tar zxvf httpd-$http_ver.tar.gz && tar zxvf httpd-$http_ver-deps.tar.gz";
    }
   
    exec {        
        "compilePCRE":
     		cwd => "/usr/local/src/pcre-$pcre_ver",
            path   => "/usr/bin:/usr/sbin:/bin",
            require => Exec['untarPCREFile'],
		    onlyif => "/usr/bin/test ! -f /usr/local/pcre/pcre-$pcre_ver",
            command => "/usr/local/src/pcre-$pcre_ver/configure --prefix=/usr/local/pcre && make && make install && touch /usr/local/pcre/pcre-$pcre_ver";
    }

    exec {        
        "compileHttpAPR":
            cwd => "/usr/local/src/httpd-$http_ver/srclib/apr",
            path   => "/usr/bin:/usr/sbin:/bin",
		    require => Exec['untarPCREFile'],    
            onlyif => "/usr/bin/test ! -f /usr/local/apr/apr-$http_ver",
            command => "sh configure --prefix=/usr/local/apr && make && make install && touch /usr/local/apr/apr-$http_ver";
    }

    exec {        
        "compileHttpAPRUtil":
            cwd => "/usr/local/src/httpd-$http_ver/srclib/apr-util",
            path   => "/usr/bin:/usr/sbin:/bin",
			require => Exec['untarPCREFile'], 
		    onlyif => "/usr/bin/test ! -f /usr/local/apr/apr-util-$http_ver",
            command => "sh configure --with-apr=/usr/local/apr  && make && make install && touch /usr/local/apr/apr-util-$http_ver";
    }

    exec {        
        "compileHttpd":
            cwd => "/usr/local/src/httpd-$http_ver",
            path   => "/usr/bin:/usr/sbin:/bin",
		    require => Exec['untarPCREFile','compileHttpAPRUtil','compileHttpAPR'],
            onlyif => "/usr/bin/test ! -f /usr/local/httpd/httpd-$http_ver",
            command => "/usr/local/src/httpd-$http_ver/configure --prefix=/usr/local/httpd --with-mpm=worker --enable-rewrite --enable-headers --enable-expires --enable-deflate=static --enable-alias=static --enable-so --enable-mods-shared=most --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr --with-pcre=/usr/local/pcre && make && make install && touch /usr/local/httpd/httpd-$http_ver";
    }

    file { "/etc/init.d/httpd": 
			owner => root, group => root, mode => 775,
			source => "puppet:///modules/eh-apache/apache-eh"
		 }

    service { "httpd":
        ensure => "running",
        enable    => true,
        require => Exec["compileHttpd"], 
    }
}
