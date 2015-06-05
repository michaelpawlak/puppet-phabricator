# == Class: phabricator::install::php
#
# This module installs PHP for use with Phabricator.
#
# === Parameters
#
# === Variables
#
# === Examples
#
class phabricator::install::php5 inherits ::phabricator::install {
  # install php with our desired
  # settings and extensions
  class { 'php':
    settings    => $php_settings,
    extensions  => $php_extensions,
    fpm         => false
  }

  # install php-fpm
  class { 'php::fpm':
    settings  => $php_fpm_settings,
    pools     => $php_fpm_pools
  }
}