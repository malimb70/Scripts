class varnish
(  
    $project 	=	'mpt',
	$storage_size	= '1',
	$inst_type = 'new',
) inherits varnish::params
{
	file { '/tmp/varnish-4.1.el6.rpm':
  		ensure => file,
  		owner  => 'root',
  		group  => 'root',
  		mode   => '0644',
  		source => 'puppet:///modules/varnish/varnish-4.1.el6.rpm',
	}
	
#	exec {'varnishrepo':
#     	cwd => '/etc/yum.repos.d',
#        path   => "/usr/bin:/usr/sbin:/bin",
#        creates => '/etc/yum.repos.d/varnish.repo',
#	     require => File['/tmp/varnish-4.1.el6.rpm'],
#        command => "rpm --nosignature -U /tmp/varnish-4.1.el6.rpm";
#    }

	file { '/etc/yum.repos.d/varnish.repo':
  		ensure => file,
  		owner  => 'root',
  		group  => 'root',
  		mode   => '0644',
  		source => 'puppet:///modules/varnish/varnish.repo',
	}
	
	file { '/etc/yum.repos.d/varnish-4.1-plus.repo':
  		ensure => file,
  		owner  => 'root',
  		group  => 'root',
  		mode   => '0644',
  		source => 'puppet:///modules/varnish/varnish-4.1-plus.repo',
	}

	exec {'cleanrepo':
     	cwd => '/etc/yum.repos.d',
        path   => "/usr/bin:/usr/sbin:/bin",
	    require => File['/etc/yum.repos.d/varnish.repo'],
       command => "yum clean all";
    }

	file { '/tmp/varnish-agent-4.1.1-1.el6.x86_64.rpm':
  		ensure => file,
  		owner  => 'root',
  		group  => 'root',
  		mode   => '0644',
  		source => 'puppet:///modules/varnish/varnish-agent-4.1.1-1.el6.x86_64.rpm',
	}
	
	exec {"varnishagent":
		cwd => '/root/',
		path   => "/usr/bin:/usr/sbin:/bin",
		creates => '/root/',
		require => [Package['varnish-plus'],File['/tmp/varnish-agent-4.1.1-1.el6.x86_64.rpm']],
		command => "yum install -y /tmp/varnish-agent-4.1.1-1.el6.x86_64.rpm";
	}
	
    #exec {"installvarnish":
	#	cwd => '/root/',
	#	path   => "/usr/bin:/usr/sbin:/bin",
	#	creates => '/root/',
	#	require => Exec['varnishrepo'],
	#	command => "yum -y install varnish-plusvarnish-agent varnish-custom-statistics-probe varnish-plus-addon-ssl varnish-plus-vmods subversion automake libtool varnish-agent";
	#}

	package { 'varnish-custom-statistics' :
		ensure => absent,
	}
	
	$packageList = ['varnish-plus', 'jemalloc', 'varnish-custom-statistics-probe', 'varnish-agent', 'varnish-plus-addon-ssl', 'subversion', 'git', 'automake', 'libtool', 'varnish-plus-libs-devel']

	package { $packageList :
		ensure => latest,
		require => [Exec['cleanrepo'],File['/etc/yum.repos.d/varnish.repo'],File['/etc/yum.repos.d/varnish-4.1-plus.repo']]
	}

	if ( ($::hostname =~ /^mptlvc/) or ($::hostname =~ /^mptlstglvc/) )
	{
		$vacIP = "172.30.30.178"
	}
	elsif ( $::hostname =~ /^wte/ )
	{
		$vacIP = "172.28.30.56"
	}
	elsif (($::ehenv == 'dev') or ($::ehenv == 'qa1') or ($::ehenv == 'qa2') or ($::ehenv == 'qa3'))
    { 
		if $project == 'mpt'
		{	$vacIP = "172.30.46.174" }
		elsif $project == 'eh'
		{	$vacIP = "10.133.121.110" }
		elsif $project == 'wte'
		{	$vacIP = "10.133.121.146" }
		elsif $project == 'img'
		{	$vacIP = "10.133.121.143" }
	}
	else
	{
		$vacIP = "10.133.105.137"
	}	
	
	file { "/etc/sysconfig/varnish-agent":
        ensure => file,
        owner   => root, group => root, mode => 755,
        require => [File['/etc/yum.repos.d/varnish.repo'],File['/etc/yum.repos.d/varnish-4.1-plus.repo'], Package['varnish-plus']],
        content => template("varnish/varnish-agent.erb");
  }

	file { "/etc/sysconfig/vstatdprobe":
        ensure => file,
        owner   => root, group => root, mode => 755,
        require => [File['/etc/yum.repos.d/varnish.repo'],File['/etc/yum.repos.d/varnish-4.1-plus.repo'],Package['varnish-plus']],
        content => template("varnish/vstatdprobe.erb");
  }

    if  $project == 'mpt' {
    	$efile = "hitch-conf-mpt.erb"
    }
    elsif $project == 'eh'
    {
    	$efile = "hitch-conf-eh.erb"
    }
	elsif $project == 'img'
    {
    	$efile = "hitch-conf-img.erb"
    }
    elsif $project == "wte"
    {
    	$efile = "hitch-conf-wte.erb"
    }
    
	if $project == 'mpt' {
    	$myfiles = [ "star.medpagetoday.com.pem" ,"api.medpagetoday.com.pem", "inp.medpagetoday.com.pem", "www.medpagetoday.com.pem", ]
    }
    elsif $project == 'eh'
    {
    	$myfiles = [ "star.everydayhealth.com.pem", "star.my-calorie-counter.com.chained.pem", ]
    }
    elsif $project == 'wte'
    {
    	$myfiles = [ "star.whattoexpect.com.pem", ]
    }
	elsif $project == 'img'
    {
		if $::ehenv == 'dev'
		{   $myfiles = [ "content.dev.everydayhealth.com.pem", ] }
		elsif $::ehenv == 'qa1'
		{	$myfiles = [ "content.qa1.everydayhealth.com.pem", ] }
		elsif $::ehenv == 'stage'
		{	$myfiles = [ "content.stage.everydayhealth.com.pem", ] }
		elsif $::ehenv == 'prod'
		{   $myfiles = [ "star.everydayhealth.com.pem", ]	}
    }

	
	define myResource { 
		file { "/etc/hitch/$name" :
			ensure => file,
			owner   => root, group => root, mode => 644,
			require => [File['/etc/yum.repos.d/varnish.repo'],File['/etc/yum.repos.d/varnish-4.1-plus.repo'],Package['varnish-plus']],
			source => "puppet:///modules/varnish/$name";
		}
	}
	
	myResource { $myfiles: }
	
	file { "/etc/hitch/hitch.conf":
        ensure => file,
        owner   => root, group => root, mode => 644,
        content => template("varnish/${efile}"),
  }
	
	file { "/etc/sysconfig/varnish":
      ensure => file,
      owner   => root, group => root, mode => 644,
      require => Package['varnish-plus'],
      content => template("varnish/varnish-conf.erb"),
  }
	
  file { "/tmp/varnish4":
      ensure => 'directory',
      owner   => root, group => root, mode => 644,
      require => Package['varnish-plus'],
  }
  
  $uproj=upcase($project)
	
	if ( ($::hostname =~ /^mpt/) and ($::ehenv == 'dev'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/mpt_dev/"
      $locpath="/tmp/varnish4/mpt_dev/*.vcl"
    }
	if ( ($::hostname =~ /^mpt/) and ($::ehenv == 'qa1'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/mpt_qa1/"
      $locpath="/tmp/varnish4/mpt_dev/*.vcl"
    }
	if ( ($::hostname =~ /^mpt/) and ($::ehenv == 'stage'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/mpt_stage/"
      $locpath="/tmp/varnish4/mpt_stage/*.vcl"
    }
	if ( ($::hostname =~ /^mpt/) and ($::ehenv == 'prod'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/mpt_prod/"
      $locpath="/tmp/varnish4/mpt_prod/*.vcl"
    }
    if ( ($::hostname =~ /^aws/) and ($::ehenv == 'stage'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/awse_stage/"
      $locpath="/tmp/varnish4/awse_stage/*.vcl"
    }
    elsif (($::hostname =~ /^aws/) and ($::ehenv == 'prod'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/awse_prod/" 
      $locpath="/tmp/varnish4/awse_prod/*.vcl"
    }
    elsif (($::hostname =~ /usnj/) and ($::ehenv == 'stage'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/stage/" 
      $locpath="/tmp/varnish4/stage/*.vcl"
    }
    elsif (($::hostname =~ /usnj/) and ($::ehenv == 'prod'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/prod/"
      $locpath="/tmp/varnish4/prod/*.vcl"
    }
    elsif (($::hostname =~ /usnj/) and ($::ehenv == 'dev'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/dev/" 
      $locpath="/tmp/varnish4/dev/*.vcl"
    }
    elsif (($::hostname =~ /usnj/) and ($::ehenv == 'qa1'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/qa1/" 
      $locpath="/tmp/varnish4/qa1/*.vcl"
    }
	elsif (($::hostname =~ /usnj/) and ($::ehenv == 'qa2'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/qa2/" 
      $locpath="/tmp/varnish4/qa2/*.vcl"
    }
	elsif (($::hostname =~ /usnj/) and ($::ehenv == 'qa3'))
    { 
      $svnpath="http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/Varnish\ 4\.0/$uproj/backends/qa3/" 
      $locpath="/tmp/varnish4/qa3/*.vcl"
    }
	
    exec {"syncrepo":
		cwd => '/tmp/varnish4',
		path   => "/usr/bin:/usr/sbin:/bin",
		creates => '/tmp/varnish4/backends/',
		require => [Package['varnish-plus'],File['/tmp/varnish4']],
		command => "svn co $svnpath;mkdir -p /etc/varnish/backends/; /bin/cp -f $locpath /etc/varnish/backends/";
    }

	file { "/etc/varnish/backends/":
		ensure => 'directory',
		owner   => root, group => root, mode => 644,
		require => Exec["syncrepo"],
	}

	service { "hitch":
		ensure => "running",
		enable    => true,
		require => [ Package['varnish-plus'], File['/etc/hitch/hitch.conf'] ] 
	}
	
	service { "varnish":
		ensure => "running",
		enable    => true,
		require => [ Package['varnish-plus'], File['/etc/sysconfig/varnish'], Exec['syncrepo'] ] 
	}
	
	service { "vstatdprobe":
		ensure => "running",
		enable    => true,
		require => File['/etc/sysconfig/vstatdprobe']
	}
	
	service { "varnish-agent":
		ensure => "running",
		enable    => true,
		require => [File['/etc/sysconfig/varnish-agent'], Exec['varnishagent']]
	}
}
