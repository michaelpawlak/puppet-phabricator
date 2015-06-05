# == Class: phabricator::db
#
# This module manages the Phabricator Database.
#
# === Parameters
#
# === Variables
#
# === Examples
#
class phabricator::database inherits ::phabricator {
  # install db first if necessary
  anchor { 'phabricator::database::begin': } ->

  # if module is managing mysql
  # create a local database instance
  if $manage_mysql {
    # create the mysql password hash
    $mysql_pw_hash  = mysql_password("${mysql_pass}")
    $mysql_tables = 'phabricator_%.*'

    # setup mysql in order
    anchor { 'phabricator::db::begin': } ->
    # install mysql
    class { 'mysql::server':
      override_options        => $mysql_options,
      root_password           => $mysql_root_password,
      restart                 => true,
      remove_default_accounts => true,
    } ->

    # create the mysql user
    mysql_user { "${mysql_user}@${base_uri}":
      ensure        => present,
      password_hash => $mysql_pw_hash,
      provider      => 'mysql'
    } ->

    # create the mysql user
    mysql_user { "${mysql_user}@localhost":
      ensure        => present,
      password_hash => $mysql_pw_hash,
      provider      => 'mysql'
    } ->

    # create our mysql user
    mysql_grant { "${mysql_user}@${base_uri}/${mysql_tables}":
      ensure      => present,
      options     => ['GRANT'],
      privileges  => ['ALL'],
      table       => $mysql_tables,
      user        => "${mysql_user}@${base_uri}",
      require     => Class['mysql::server'],
    } ->

    # create our mysql user
    mysql_grant { "${mysql_user}@localhost/${mysql_tables}":
      ensure      => present,
      options     => ['GRANT'],
      privileges  => ['ALL'],
      table       => $mysql_tables,
      user        => "${mysql_user}@localhost",
      require     => Class['mysql::server'],
    } ->

    # execute phabricator storage upgrade
    exec { 'storage-upgrade':
      command   => "${base_dir}/phabricator/bin/storage upgrade --force",
      logoutput => true,
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      unless    => "${base_dir}/phabricator/bin/storage status",
      require   => [
        Class['phabricator::install']
      ],
      subscribe => [
        Vcsrepo["${base_dir}/phabricator"],
        File["${base_dir}/phabricator/conf/local/local.json"]
      ]
    } ->
    anchor { 'phabricator::db::end': }
  }
  else {
    # execute phabricator storage upgrade
    exec { 'storage-upgrade':
      command   => "${base_dir}/phabricator/bin/storage upgrade --force",
      logoutput => true,
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      unless    => "${base_dir}/phabricator/bin/storage status",
      require   => [
        Class['phabricator::install']
      ],
      subscribe => [
        Vcsrepo["${base_dir}/phabricator"],
        File["${base_dir}/phabricator/conf/local/local.json"]
      ]
    }
  } ->
  anchor { 'phabricator::database::end': }
}
