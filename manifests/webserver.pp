# == Class: phabricator::web
#
# This module manages the Phabricator web server.
#
# === Parameters
#
# [*domain*]
#
# === Variables
#
# === Examples
#
class phabricator::webserver inherits ::phabricator {
  # install nginx
  include nginx

# define a variable for the fpm listening address
  $php_phabricator_pool = $php_fpm_pools['phabricator']
  $php_fpm_listen = $php_phabricator_pool['listen']

  # setup our virtual host
  nginx::resource::vhost { "${base_uri}":
    ensure                => 'present',
    www_root              => "${base_dir}/phabricator/webroot",
    index_files           => [],
    access_log            => $nginx_access_log,
    error_log             => $nginx_error_log,
    ssl                   => $nginx_ssl,
    ssl_cert              => $nginx_ssl_cert,
    ssl_key               => $nginx_ssl_key,
    ssl_protocols         => $nginx_ssl_protocols,
    ssl_ciphers           => $ssl_ciphers,
    rewrite_to_https      => $nginx_rewrite_to_https,
    vhost_cfg_prepend     => $nginx_vhost_cfg_prepend,
    vhost_cfg_append      => {
      'try_files' => '$uri $uri/ /index.php',
    },
    use_default_location  => false
  }

  # setup the root location
  nginx::resource::location { "${base_uri}/":
    ensure        => 'present',
    location      => '/',
    vhost         => "${base_uri}",
    location_custom_cfg => {
      'index'   => 'index.php',
      'rewrite' => '^/(.*)$ /index.php?__path__=/$1 last'
    }
  }

  # setup rsrc location
  nginx::resource::location { "${base_uri}/rsrc/":
    ensure              => 'present',
    location            => '/rsrc/',
    vhost               => "${base_uri}",
    location_custom_cfg => {
      try_files => '$uri $uri/ =404',
    },
  }

  # setup favicon.ico location
  nginx::resource::location { "${base_uri}/favicon.ico":
    ensure              => 'present',
    location            => '/favicon.ico',
    vhost               => "${base_uri}",
    location_custom_cfg => {
      try_files => '$uri =204',
    },
  }

  # setup ~.php location
  nginx::resource::location { "${base_uri}/~ \\.php$":
    ensure                => 'present',
    location              => '~ \.php$',
    vhost                 => "${base_uri}",
    fastcgi               => $php_fpm_listen,
    location_cfg_prepend  => {
      'fastcgi_index' => 'index.php',
    },
    fastcgi_param         => $nginx_fastcgi_param,
  }

  # setup the reverse proxy
  nginx::resource::upstream { 'phabricator_rack_app':
    ensure  => present,
    members => [
      "${php_fpm_listen}",
    ],
  }

  # setup the monitor vhost
  nginx::resource::vhost { 'monitor':
    ensure               => 'present',
    listen_ip            => '127.0.0.1',
    listen_port          => '8080',
    location_allow       => ['127.0.0.1'],
    index_files          => [],
    access_log           => "${nginx_log_root}/localhost_access.log",
    error_log            => "${nginx_log_root}/localhost_error.log",
    use_default_location => false,
  }

  # if ping is defined, configure it
  if $php_phabricator_pool['ping_path'] {
    $php_ping_path  = $php_phabricator_pool['ping_path']
    nginx::resource::location { 'monitor/ping':
      ensure    => 'present',
      location  => $ping_path,
      vhost     => 'monitor',
      fastcgi   => 'phabricator_rack_app',
    }
  }

  # if status is defined, configure i
  if $php_phabricator_pool['pm_status_path'] {
    $php_status_path  = $php_phabricator_pool['pm_status_path']
    nginx::resource::location { 'monitor/status':
      ensure   => 'present',
      location => $php_status_path,
      vhost    => 'monitor',
      fastcgi  => 'phabricator_rack_app',
    }
  }

  # install webserver specific packages
  ensure_packages($web_packages)
}
