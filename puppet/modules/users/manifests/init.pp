class users
{
	case $::operatingsystem {
      'FreeBSD' : {
		group { 'sudosh-users':
  			ensure  => 'present',
  			gid     => '185',
		}


		group { 'varnishusers':
  			ensure  => 'present',
  			gid     => '186',
		}


                group { 'jpatel':
                        ensure  => 'present',
                        gid     => '1019',
                }

		user { 'jpatel':
			ensure   => 'present',
			comment  => 'Jasmin Patel',
			gid      => '1019',
			home     => '/usr/home/jpatel',
			password => '$6$hIk4T0saoO.JjQmj$WpmnWpZ47GdlU.GP6z0yv1ysOiOwbzj4jnYvcmVUJ/duGTlHLGhMy1L5tIW0WB4/OQEDr4FK1kyj5IHEJXsdo1',
			shell    => '/usr/local/bin/bash',
			uid      => '1019',
		}
		file { '/usr/home/jpatel':
                    ensure => 'directory',
                    owner  => 'jpatel',
                    group  => 'jpatel',
                    mode   => '0755',
                }
		user { 'kgrefski':
			ensure   => 'present',
			comment  => 'Keith Grefski',
			gid      => '185',
			groups   => ['sudosh-users', 'varnishusers'],
			home     => '/usr/home/kgrefski',
			password => '$1$WP61MCHD$zg6oB3PF9eUcYWMU18ZAK1',
			shell    => '/usr/local/bin/bash',
			uid      => '1004',
		}
		file { '/usr/home/kgrefski':
	            ensure => 'directory',
    		    owner  => 'kgrefski',
    		    group  => 'sudosh-users',
    		    mode   => '0755',
		}

		user { 'sraju':
			ensure   => 'present',
			comment  => 'Srinivasa Raju',
			gid      => '185',
			groups   => ['sudosh-users', 'varnishusers'],
			home     => '/home/sraju',
			password => '$6$LLGlwGNNGm3Xv1bl$IW9zrEIKVKI9I3QMbVMzVBiBqMyazK5ORWs1f/uvxr3pAOzXAbPcBSCAiv0LQaViWdTLhQzP1voLLMe8Mq12N.',
			shell    => '/usr/local/bin/bash',
			uid      => '1017',
		}

		file { '/usr/home/sraju':
                    ensure => 'directory',
                    owner  => 'sraju',
                    group  => 'sudosh-users',
                    mode   => '0755',
                }

		user { 'jfinucane':
			ensure   => 'present',
			comment  => 'Jim Finucane',
			gid      => '185',
			groups   => ['sudosh-users', 'varnishusers'],
			home     => '/home/jfinucane',
			password => '$1$3E59.woP$n.cv.VOS3T0HhjiONWPrg/',
			shell    => '/usr/local/bin/bash',
			uid      => '1014',
		}
		
		file { '/usr/home/jfinucane':
                    ensure => 'directory',
                    owner  => 'jfinucane',
                    group  => 'sudosh-users',
                    mode   => '0755',
                }

		user { 'mpritchett':
			ensure   => 'present',
			comment  => 'Marvin Pritchet',
			gid      => '185',
			groups   => ['sudosh-users', 'varnishusers'],
			home     => '/home/mpritchett',
			password => '$1$VAp/HH8D$MqXNuElXEtUFMQJn0NFvv.',
			shell    => '/usr/local/bin/bash',
			uid      => '1011',
		}
		
		file { '/usr/home/mpritchett':
                    ensure => 'directory',
                    owner  => 'mpritchett',
                    group  => 'sudosh-users',
                    mode   => '0755',
                }

		user { 'mbaig':
			ensure   => 'present',
			comment  => 'Mirza Baig',
			gid      => '185',
			groups   => ['sudosh-users', 'varnishusers'],
			home     => '/home/mbaig',
			password => '$6$NrjyZHFYKqbeRAbk$sXjulEwYxvjKliGJVnUDBEM/tVMgjzrJzOkKvdvkGpW7V/JV3EVB0ITHGhJgLYvLFQVSGis4zcTJ/65SXPGxz/',
			shell    => '/usr/local/bin/bash',
			uid      => '1020',
		}
		
		file { '/usr/home/mbaig':
                    ensure => 'directory',
                    owner  => 'mbaig',
                    group  => 'sudosh-users',
                    mode   => '0755',
                }

		user { 'jchan':
			ensure   => 'present',
			comment  => 'Jinwah Chan',
			gid      => '185',
			groups   => ['sudosh-users', 'varnishusers'],
			home     => '/home/jchan',
			password => '$1$MKBXdDto$ApdEJPhcP8HHRUjD.5CMo.',
			shell    => '/bin/sh',
			uid      => '1010',
		}
		file { '/usr/home/jchan':
                    ensure => 'directory',
                    owner  => 'jchan',
                    group  => 'sudosh-users',
                    mode   => '0755',
                }
	
		user { 'ndasari':
		  	ensure   => 'present',
  			comment  => 'Nagababu dasari',
  			gid      => '185',
  			groups   => ['varnishusers', 'sudosh-users'],
  			home     => '/usr/home/ndasari',
  			password => '$6$UBeEupavcQ7wrGIc$eQ9ys8pqXAB/f3UKkzClImn8cqVkFFUmfMDObjfA.MWjaHWr3DhNOl5qhiIAGXXxfR2KyAZlLmRJ1M2LxDtA91',
  			shell    => '/usr/local/bin/bash',
  			uid      => '1018',
		}
		file { '/usr/home/ndasari':
                    ensure => 'directory',
                    owner  => 'ndasari',
                    group  => 'sudosh-users',
                    mode   => '0755',
                }
		
		user { 'dnelovic':
  			ensure   => 'present',
  			comment  => 'Dino Nelovic',
  			gid      => '0',
			groups   => ['varnishusers', 'sudosh-users'],
  			home     => '/usr/home/dnelovic',
  			password => '$6$SAhzKAXb3kAOwhzP$DsI9/Nb3IqH7stQrofkTBKaNHqgM58Lk6SbOGXl3RqRMa3W6huv/F.jhYzkyZcEsSEpCF2qfD4zrV8Wh9PCn8/',
  			shell    => '/bin/sh',
  			uid      => '1002',
		}
		file { '/usr/home/dnelovic':
                    ensure => 'directory',
                    owner  => 'dnelovic',
                    group  => 'wheel',
                    mode   => '0755',
                }
          }
	} 
}
