class nagios::server (

	$nag_svr_plugin_root = '/usr/lib64/nagios/plugins'

) {

	$nagios_scripts = [
	]

    $nagios_server = [
		'nagios', 'nagios-devel',
		'unixODBC', 'perl-DBD-ODBC',
		'python-memcached', 'perl-DBD-mysql',
		'perl-Module-Build',
		'perl-Archive-Tar',
		'perl-ExtUtils-CBuilder',
		'perl-IO-Zlib',
		'perl-Package-Constants'
	]

    package {
        $nagios_server:
			ensure => 'installed'
    }

	# get code

	service {
		'nagios':
			ensure => 'running',
			hasrestart => true,
	}

	create_resources(file,
		{
			"${nag_svr_plugin_root}/authentication.py" => { content => template('nagios/server_plugins/authentication.py') },
			"${nag_svr_plugin_root}/carepages_bj_job_stats.pl" => { content => template('nagios/server_plugins/carepages_bj_job_stats.pl') },
			"${nag_svr_plugin_root}/carepages_emails_stats.pl" => { content => template('nagios/server_plugins/carepages_emails_stats.pl') },
			"${nag_svr_plugin_root}/check_couchbase.py" => { content => template('nagios/server_plugins/check_couchbase.py') },
			"${nag_svr_plugin_root}/check_dshi-heartbeat.pl" => { content => template('nagios/server_plugins/check_dshi-heartbeat.pl') },
			"${nag_svr_plugin_root}/check_farms.pl" => { content => template('nagios/server_plugins/check_farms.pl') },
			"${nag_svr_plugin_root}/check_fastsearch.pl" => { content => template('nagios/server_plugins/check_fastsearch.pl') },
			"${nag_svr_plugin_root}/check_http.pl" => { content => template('nagios/server_plugins/check_http.pl') },
			"${nag_svr_plugin_root}/check_http_redirect.pl" => { content => template('nagios/server_plugins/check_http_redirect.pl') },
			"${nag_svr_plugin_root}/check_long_time_threads.pl" => { content => template('nagios/server_plugins/check_long_time_threads.pl') },
			"${nag_svr_plugin_root}/check_memcached.py" => { content => template('nagios/server_plugins/check_memcached.py') },
			"${nag_svr_plugin_root}/check_netapp2.pl" => { content => template('nagios/server_plugins/check_netapp2.pl') },
			"${nag_svr_plugin_root}/check_netapp_volumes.pl" => { content => template('nagios/server_plugins/check_netapp_volumes.pl') },
			"${nag_svr_plugin_root}/check_nlqueue.pl" => { content => template('nagios/server_plugins/check_nlqueue.pl') },
			"${nag_svr_plugin_root}/check_san_mem.pl" => { content => template('nagios/server_plugins/check_san_mem.pl') },
			"${nag_svr_plugin_root}/check_vmware_api.pl" => { content => template('nagios/server_plugins/check_vmware_api.pl') },
			"${nag_svr_plugin_root}/check_winservice.pl" => { content => template('nagios/server_plugins/check_winservice.pl') },
			"${nag_svr_plugin_root}/esg-drugs.py" => { content => template('nagios/server_plugins/esg-drugs.py') },
			"${nag_svr_plugin_root}/esg-leadgen.py" => { content => template('nagios/server_plugins/esg-leadgen.py') },
			"${nag_svr_plugin_root}/forums_content_stats.pl" => { content => template('nagios/server_plugins/forums_content_stats.pl') },
			"${nag_svr_plugin_root}/forums_delayed_jobs_stats.pl" => { content => template('nagios/server_plugins/forums_delayed_jobs_stats.pl') },
			"${nag_svr_plugin_root}/generate_drugs_delayed_jobs_stats.pl" => { content => template('nagios/server_plugins/generate_drugs_delayed_jobs_stats.pl') },
			"${nag_svr_plugin_root}/generate_forums_delayed_jobs_stats.pl" => { content => template('nagios/server_plugins/generate_forums_delayed_jobs_stats.pl') },
			"${nag_svr_plugin_root}/healthdataservices_userhealthprofile.py" => { content => template('nagios/server_plugins/healthdataservices_userhealthprofile.py') },
			"${nag_svr_plugin_root}/limelight_monthly_usage.py" => { content => template('nagios/server_plugins/limelight_monthly_usage.py') },
			"${nag_svr_plugin_root}/registration.py" => { content => template('nagios/server_plugins/registration.py') },
			"${nag_svr_plugin_root}/rhg_check_replicates.pl" => { content => template('nagios/server_plugins/rhg_check_replicates.pl') },
			"${nag_svr_plugin_root}/syncgateway.py" => { content => template('nagios/server_plugins/syncgateway.py') },
			"${nag_svr_plugin_root}/userservice-cp.py" => { content => template('nagios/server_plugins/userservice-cp.py') },
			"${nag_svr_plugin_root}/utils.py" => { content => template('nagios/server_plugins/utils.py') },
			"${nag_svr_plugin_root}/utils.pm" => { content => template('nagios/server_plugins/utils.pm') },
		},
		{
			ensure => present,
			mode => 0775,
			owner => 'root',
			group => 'nagios'
		}
	)

	file {
		"/usr/local/lib/perl/":
			ensure => directory,
			owner => 'root',
			group => 'root',
            mode    => "775"
	}

	file {
        "/usr/local/lib/perl/NetApp":
            ensure  => "directory",
            recurse => true,
            owner   => "root",
            group   => "root",
            mode    => "775",
            source  => "puppet:///modules/nagios/NetApp",
			require => File["/usr/local/lib/perl/"]
	}


}

