class phagrancy::poweredby::apache {
	class { 'apache':
		default_vhost => false,
		manage_group  => false,
		manage_user   => false,
		timeout		  => $phagrancy::timeout,
	}

	# class { 'apache_hardening':
 #  		provider => 'puppetlabs/apache'
	# }

	class { 'apache::mod::rewrite': }
	class { 'apache::mod::proxy': }
	class { 'apache::mod::proxy_fcgi': }

	apache::vhost { $fqdn:
		port          => '80',
		  directories => [
    { path        => $phagrancy::docroot,
      addhandlers => [{ handler => '"proxy:fcgi://127.0.0.1:9000/"', extensions => ['.php']}],
      allow_override => 'All'
    },
  ],
		docroot       => $phagrancy::docroot,
		docroot_owner => $phagrancy::owner,
		docroot_group => $phagrancy::owner,
	}
}