class varnishd (
	$varnish_user = 'www';
	$varnish_group = 'www';
	$varnish_version = '3.0.2';
	$varnish_root = '/usr/local';
	$varnish_enable = true;
	$varnish_sites = [];
) {

	$sitenames = $varnish_sites

	realize(User["${varnish_user}"])
	realize(Group["${varnish_group}"])

	# init script
	file {
		"/usr/local/etc/rc.d/varnishd":
			ensure  => directory,
			owner   => $user,
			group   => $group,
			mode    => 0755,
			content => template("varnishd/init/varnishd.erb')

		"/usr/local/etc/rc.d/varnishnsca_${sitenames}":
			ensure  => directory,
			owner   => $user,
			group   => $group,
			mode    => 0755,
			content => template("varnishd/init/varnishnsca_${sitenames}.erb')
	}

	# varnish structure
	file {
		"/usr/local/var":
			ensure  => Directory,
			owner   => $varnish_user,
			group   => $varnish_group,
			mode    => 0755
		"/var/log/varnish":
			ensure  => Directory,
			owner   => $varnish_user,
			group   => $varnish_group,
			mode    => 0755
		"/var/log/varnish/fetcherror":
			ensure  => Directory,
			owner   => $varnish_user,
			group   => $varnish_group,
			mode    => 0755
		"/usr/local/var":
			ensure  => Directory,
			owner   => $varnish_user,
			group   => $varnish_group,
			mode    => 0755
		"/usr/local/var/varnish":
			ensure  => Directory,
			owner   => $varnish_user,
			group   => $varnish_group,
			mode    => 0755
		"/usr/local/var/varnish/${fqdn}":
			ensure  => Directory,
			owner   => $varnish_user,
			group   => $varnish_group,
			mode    => 0755
		"/usr/local/bin":
			ensure  => "directory",
			recurse => true,
			owner   => $admin_u,
			group   => $admin_g,
			mode    => "775",
			source  => "puppet://modules/varnishd/files/bin"
	}

#
#  puppet module install puppetlabs-vcsrepo
#
	
	vcsrepo { "${root_cfgdir}/varnish":
		ensure => present,
		provider => svn,
		source => 'http://usnjlsvn02.waterfrontmedia.net/repos/network-ops/varnish/trunk',
		onlyif => 'test ! -f /usr/local/etc/varnish/eh-error.vcl'
	}
}
