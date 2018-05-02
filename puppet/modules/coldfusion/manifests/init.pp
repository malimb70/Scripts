class coldfusion  {
	$packagelist = ["httpd", "nfs-utils", "wget", "firewalld", "epel-release-7-6.noarch"]
    package { $packagelist: ensure => installed }

    file { "/etc/httpd/conf/httpd.conf":
			ensure => file,
			owner => root, group => root, mode => 644,
			require => Package["httpd"],
			notify  => Service['httpd'],
			source =>["puppet:///modules/coldfusion/httpd.conf-mpt_cf"];

		"/etc/httpd/conf/mod_jk.conf":
			ensure => file,
			owner => root, group => root, mode => 644,
			require => Package["httpd"],
			notify  => Service['httpd'],
			source =>["puppet:///modules/coldfusion/mod_jk.conf"];
		
        "/etc/httpd/conf/extra/eh_header.conf":
            ensure => file,
            owner   => apache, group => apache, mode => 755,
			require => Package["httpd"],
			notify  => Service['httpd'],
            content => template("coldfusion/eh_header.erb");

		"/etc/httpd/conf/extra/web_medpagetoday.conf":
            ensure => file,
            owner   => apache, group => apache, mode => 755,
			require => Package["httpd"],
			notify  => Service['httpd'],
            content => template("coldfusion/web_medpagetoday.erb");

		"/etc/httpd/conf/extra/web_cfide_admin.conf":
            ensure => file,
            owner   => apache, group => apache, mode => 755,
			require => Package["httpd"],
			notify  => Service['httpd'],
            content => template("coldfusion/web_cfide_admin.erb");			
			
        "/etc/httpd/conf/extra":
            path => '/etc/httpd/conf/extra',
			owner   => apache, group => apache, mode => 755,
            ensure => directory,
            require => Package["httpd"],
            notify  => Service['httpd'],
         #  require => File['/etc/httpd/conf/httpd.conf'],
            source  => ['puppet:///modules/coldfusion/extra'],
            recurse => true;
    }

    service { "httpd":
        enable => "true",
        ensure => "running",
        hasrestart => "true",
        hasstatus => "true",
        require => [ File["/etc/httpd/conf/httpd.conf"], Package["httpd"], Exec["createFolder"] ],
    }

# Cold Fusion Installation

    file { "/usr/local/src/coldfusion2016-0.0-1.el6.x86_64.rpm":
        owner => root, group => root, mode => 775,
        source => "puppet:///modules/coldfusion/coldfusion2016-0.0-1.el6.x86_64.rpm";
    }

	file { "/etc/ssl/certs/star.medpagetoday.com.chained":
        owner => root, group => root, mode => 775,
        source => "puppet:///modules/coldfusion/star.medpagetoday.com.chained";
    }

	file { "/etc/ssl/certs/star.medpagetoday.com.key":
        owner => root, group => root, mode => 775,
        source => "puppet:///modules/coldfusion/star.medpagetoday.com.key";
    }
	
    exec { "coldfusion-instalation":
		cwd => '/usr/local/src',
        path   => "/usr/bin:/usr/sbin:/bin",
        onlyif => "/usr/bin/test ! -f /opt/coldfusion2016/coldfusion_rpm_installation",
        command => "rpm -ivh coldfusion2016-0.0-1.el6.x86_64.rpm; touch /opt/coldfusion2016/coldfusion_rpm_installation";
    }

    file { "/usr/lib/systemd/system/nfs-idmap.service":
        owner => root, group => root,
        require => Package["nfs-utils"],
        source => "puppet:///modules/coldfusion/nfs-idmap.service";


        "/usr/lib/systemd/system/nfs-lock.service":
            owner => root, group => root,
            require => Package["nfs-utils"],
            source => "puppet:///modules/coldfusion/nfs-lock.service";
    }

    file { "/opt/coldfusion2016/cfusion/lib/neo-cron.xml":
        ensure => file,
        owner => nobody, group => bin, mode => 644,
        source => "puppet:///modules/coldfusion/neo-cron.xml",
        require => Exec["coldfusion-instalation"];

        "/opt/coldfusion2016/cfusion/lib/neo-datasource.xml":
            ensure => file,
            owner => nobody, group => bin, mode => 644,
            content => template("coldfusion/neo-datasource.erb");
    }

    file { "/var/weblogs":
        ensure => directory,
        owner => apache, group => apache, mode => 777;

        "/mnt/medpage_content":
			ensure => directory,
			owner => apache, group => apache, mode => 755;

        "/mnt/medpage_static-htmls":
			ensure => directory,
            owner => apache, group => apache, mode => 755;
	
	}

	file { ["/var/web/", "/var/web/CFIDE/", "/var/weblogs/medpagetoday.com/", "/var/web/medpagetoday.com/content/", "/var/web/medpagetoday.com/content/devwerp", "/var/web/medpagetoday.com/content/admin", "/var/web/medpagetoday.com/content/newsengin", "/var/web/medpagetoday.com/content/stirling" ]:
		ensure => directory,
        owner => apache, 
		group => apache, 
		mode => 755;
	}
	exec {"createFolder":
        path   => "/usr/bin:/usr/sbin:/bin",
        command => "mkdir -p /var/web/medpagetoday.com/content/devwerp; mkdir -p /var/web/medpagetoday.com/content/admin; mkdir -p /var/web/medpagetoday.com/content/newsengin; mkdir -p /var/web/medpagetoday.com/content/stirling";
    }
	
    exec {"sysctl_nfs":
        path   => "/usr/bin:/usr/sbin:/bin",
        onlyif => "/usr/bin/test ! -f /etc/exports.d/nfsutils_install",
        command => "systemctl enable nfs-idmapd.service; systemctl enable rpc-statd.service; systemctl enable rpcbind.socket; touch /etc/exports.d/nfsutils_install; chattr +i /etc/exports.d/nfsutils_install";
    }

    exec { "configure_firewall":
        path   => "/usr/bin:/usr/sbin:/bin",
        onlyif => "/usr/bin/test ! -f /etc/exports.d/firewall_config_from_puppet",
        command => "firewall-cmd --zone=public --add-port=80/tcp --permanent; firewall-cmd --zone=public --add-port=8050/tcp --permanent; firewall-cmd --zone=public --add-port=3306/tcp --permanent; firewall-cmd --reload ; touch /etc/exports.d/firewall_config_from_puppet; chattr +i /etc/exports.d/firewall_config_from_puppet";
    }

    exec { "symlink_to_cfide":
		path   => "/usr/bin:/usr/sbin:/bin",
        onlyif => "/usr/bin/test ! -f /etc/exports.d/symlink_to_cfide",
        command => "ln -s /opt/coldfusion2016/cfusion/wwwroot/CFIDE/ /var/web/cfide; ln -s /opt/coldfusion2016/cfusion/wwwroot/CFIDE/ /var/web/CFIDE; touch /etc/exports.d/symlink_to_cfide; chattr +i /etc/exports.d/symlink_to_cfide";
	}
}

