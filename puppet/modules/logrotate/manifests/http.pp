class logrotate::http ($logfile_rotate = '/var/log/httpd/*log', $logfile = '/var/log/httpd/access_log', $logfile_name = 'access_log', $logdate = 'logname=$(date +%y%m%d)' ) inherits logrotate::base {

	file {
                "/etc/logrotate.d/httpd":
                        ensure  => present,
                        owner    => root,
                        group   => root,
                        mode    => 0644,
#			source	=> "puppet:///modules/logrotate/httpd_logrotate";
			content => template("logrotate/httpd_logrotate.erb");

		"/usr/local/bin/logcopy":
			ensure	=> present,
			owner	=> root,
			group	=> root,
			mode	=> 0755,
			content => template("logrotate/logcopy.erb");

        }

}
