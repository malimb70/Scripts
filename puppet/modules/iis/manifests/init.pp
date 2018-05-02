class iis
(
  $pool_names,
  $pool_ver,
  $site_name,
  $site_path,
  $site_port,
  $site_ip=$::iis::params::ip_address,
  $site_host,
  $site_pool,
  $myhash,
)
{
    define create_pool
    ( $names, $ver )
    {
		$user = $name
        iis::manage_app_pool { $user:
			enable_32_bit     => true,
            managed_runtime_version => $ver,
        }
    }

    create_pool { $pool_names:
		names => $pool_names,
        ver => $pool_ver ,
    }

	iis::manage_site {$site_name:
		site_path   => $site_path,
        port        => $site_port,
        ip_address  => $site_ip,
        host_header => $site_host,
        app_pool    => $site_pool,
    }

    define display_hash ($vdir_path,$vdir_pool,$vdir_sname) {
		file { $vdir_path:
			ensure => 'directory',
        }

        iis::manage_virtual_application {$title:
			site_name   => $vdir_sname,
            site_path   => $vdir_path,
            app_pool    => $vdir_pool,
        }
    }
    create_resources(display_hash, $myhash)
}


class iis::eh_platforms_prod
{
    iis
	{  'eh_platforms_prod':
		pool_names => ['Everydayhealth_Platform','Everydayhealth_Platform_Drugs','Everydayhealth_Platform_solutions'],
		pool_ver => 'v4.0',
		site_name => 'Everydayhealth_Platform',
		site_path => 'D:\websites\everydayhealth_Platform',
		site_port => '80',
		site_host => 'www.everydayhealth.com',
		site_pool => 'Everydayhealth_Platform',
		myhash => {
			'drugs' =>
			{
				vdir_sname => 'Everydayhealth_Platform',
				vdir_path => 'D:\websites\drugs',
				vdir_pool => 'Everydayhealth_Platform_Drugs'
			},
			'solutions' =>
			{
				vdir_sname => 'Everydayhealth_Platform',
				vdir_path => 'D:\websites\solutions',
				vdir_pool => 'Everydayhealth_Platform_solutions'
			},
		}
	}
	
	iis::manage_binding { 'www':
		site_name   => 'Everydayhealth_Platform',
        host_header => 'www.everydayhealth.com',
		protocol    => 'http',
		port        => '80',
		ip_address  => $ipaddress,
	}

	iis::manage_binding { 'platform':
		site_name   => 'Everydayhealth_Platform',
        host_header => 'platform.everydayhealth.com',
		protocol    => 'http',
		port        => '80',
		ip_address  => $ipaddress,
	}
}
