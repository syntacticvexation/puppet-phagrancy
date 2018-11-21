class phagrancy (
	$access_password,
	$api_token = undef,
	$data_dir,
	$docroot,
	$packages,
	$php_version,
	$poweredby,
	$install_dir,
	$owner,
	$repo,
	$timeout = 800,
	$user
) {
	vcsrepo { $install_dir:
		ensure => present,
		provider => git,
		source => $repo,
		user => $user,
		owner => $owner,
		group => $owner,
	}

	->

	composer::project { 'phagrancy':
       ensure  => 'installed',
       target  => $install_dir,
       dev     => true,
    }

	file { "${install_dir}/.env":
		owner => $owner,
		group => $owner,
		ensure => file,
		content => template("phagrancy/env.erb"),
		require => Vcsrepo[$install_dir],
	}

	file { $data_dir:
		ensure => directory,
		owner => $owner,
		group => $owner,
		require => Vcsrepo[$install_dir],
	}

	package { $packages:
		ensure => installed,
	}

	->

	service { "php${php_version}-fpm":
    	ensure  => 'running',
    	enable  => true,
  	}

	file_line { "php-fpm_tcp_listen":
        ensure => present,
        line => "listen = 127.0.0.1:9000",
        match => /listen =.*/,
        path => "/etc/php/${php_version}/fpm/pool.d/www.conf",
        notify => Service["php${php_version}-fpm"],
    }

	$max_times = ['execution', 'input']

	$max_times.each |$index, $time_type| {
		file_line { "php-fpm_max_${time_type}_time":
	        ensure => present,
	        line => "max_${time_type}_time = ${timeout}",
	        match => /max_${time_type}_time =.*/,
	        path => "/etc/php/${php_version}/fpm/php.ini",
	        notify => Service["php${php_version}-fpm"],
	    }
	}

	include "phagrancy::poweredby::${poweredby}"
}