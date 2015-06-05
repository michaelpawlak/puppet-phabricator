# == Class: phabricator
#
# This module initializes Phabricator.
#
# === Parameters
#
# 1. General Settings
# ==============================
# [*base_dir*]
# [*environment*]
#
# === Variables
#
# === Examples
#
class phabricator (
  #
  # 1. General Settings
  # ==============================
  $base_dir               = '/var/www/phabricator',
  $environment            = 'production',
  $user                   = $phabricator::params::user,
  $group                  = $phabricator::params::group,
  $service_ensure         = 'running',

  #
  # 2. Repo Settings
  # ==============================
  $vcs_user               = $phabricator::params::vcs_user,
  $local_repo_path        = '/opt/phabricator',
  $sudo_conf_content      = $phabricator::params::sudo_conf_content,
  $manage_ssh             = true,
  $ssh_auth_key_command   = '/usr/libexec/phabricator-ssh-hook.sh',
  $ssh_access_port        = '222',

  #
  # 2. Application Settings
  # ==============================
  $base_uri               = $::fqdn,
  $prod_uri               = undef,
  $phabricator_revision   = 'master',
  $arcanist_revision      = 'master',
  $libphutil_revision     = 'master',
  $log_file               = '/var/log/phabricator.log',
  $upload_size            = '20000000',

  #
  # 3. Database Settings
  # ==============================
  $manage_mysql           = true,
  $mysql_user             = 'phabricator',
  $mysql_pass             = 'phab_db_pass',
  $mysql_host             = 'localhost',
  $mysql_port             = '3306',
  $mysql_root_pass        = 'phab_root_pass',
  $mysql_options          = $phabricator::params::mysql_options,

  #
  # 4. Webserver Settings
  # ==============================
  $manage_nginx           = true,
  $nginx_ssl              = false,
  $nginx_ssl_cert         = undef,
  $nginx_ssl_key          = undef,
  $nginx_ssl_protocols    = 'TLSv1 TLSv1.1 TLSv1.2',
  $nginx_ssl_ciphers      = undef,
  $nginx_rewrite_to_https = undef,
  $nginx_access_log       = $phabricator::params::nginx_access_log,
  $nginx_error_log        = $phabricator::params::nginx_error_log,
  $nginx_http_cfg_append  = $phabricator::params::nginx_http_cfg_append,
  $nginx_fastcgi_param    = $phabricator::params::nginx_fastcgi_param,

  #
  # 5. PHP Settings
  # ==============================
  $php_settings           = $phabricator::params::php_settings,
  $php_extensions         = $phabricator::params::php_extensions,
  $php_fpm_settings       = $phabricator::params::php_fpm_settings,
  $php_fpm_pools          = $phabricator::params::php_fpm_pools,

  #
  # 6. Service Settings
  # ==============================
  $service_ensure         = 'running',
  $service_enable         = true,
  $service_hasrestart     = true,
  $service_hasstatus      = true
  ) inherits phabricator::params {

  unless $nginx_ssl_ciphers {
    $ssl_ciphers  = template('phabricator/nginx.ciphers')
  } else {
    $ssl_ciphers  = $nginx_ssl_ciphers
  }

  # validate general settings
  validate_absolute_path($base_dir)
  validate_re($environment, ['development', 'production'])
  validate_string($user)

  anchor { 'phabricator::begin': } ->
  class { 'phabricator::base': } ->
  class { 'phabricator::install': } ->
  class { 'phabricator::config': } ->
  class { 'phabricator::database': } ->
  class { 'phabricator::webserver': } ->
  class { 'phabricator::service': } ->
  anchor { 'phabricator::end': }
}
