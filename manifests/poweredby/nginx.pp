class phagrancy::poweredby::nginx {
	class { 'nginx':
		manage_repo => false,
		server_purge => true,
	}

	# workaround for https://github.com/voxpupuli/puppet-nginx/issues/996 
	# file { '/etc/nginx/sites-enabled/default':
	# 	ensure => absent,
	# }

	nginx::resource::server{ $fqdn:
		client_max_body_size	=> '7G',
		error_log				=> '/tmp/nginx_ph_log debug',
		proxy_read_timeout		=> "$phagrancy::timeout",
		error_pages				=>	{'404' => '/404.html',
					 				'500 502 503 504' => '/50x.html'},
		listen_port				=> 443,
		ssl						=> true,
		ssl_cert           		=> "/etc/letsencrypt/live/${fqdn}/fullchain.pem",
  		ssl_key		            => "/etc/letsencrypt/live/${fqdn}/privkey.pem",
		ssl_port				=> 443,
		www_root				=> $phagrancy::docroot,
		index_files 			=> ['index.php'],
	 	try_files 				=> ['$uri', '$uri/', '/index.php$is_args$args'],

	 	locations => {
	 		'nginx_error'	=> {
	 			location		=> '= /50x.html',
	 			www_root		=> '/usr/local/share/nginx/www',
	 		},
	 		'phagrancy_php' => {
	 			location        			=> '~ [^/]\.php(/|$)',
	 			location_custom_cfg_prepend => {
	 				'if' => '(!-f $document_root$fastcgi_script_name) {
	return 404;
    }',
					'fastcgi_read_timeout' => "$phagrancy::timeout;"
	 			},
	 			fastcgi        				=> "127.0.0.1:9000",
	 			fastcgi_split_path			=> '^(.+?\.php)(/.*)$',
	 			include						=> ['fastcgi_params'],
	 			fastcgi_param				=> {
      				'SCRIPT_FILENAME'  => '$document_root$fastcgi_script_name',
   				}
	 		}
	 	}
	}
}