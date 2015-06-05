class phabricator::service::phd inherits ::phabricator::service {
  # create our temp directories
  file { ['/var/tmp/phd',
          '/var/tmp/phd/pid',
          '/var/tmp/phd/log']:
    ensure  => directory,
    owner   => $user,
    group   => $group,
  }

  # create our init script
  file { '/etc/init.d/phd':
    ensure  => present,
    mode    => '0755',
    content => template('phabricator/phd.erb'),
    notify  => Service['phd']
  }

  # define our service
  service { 'phd':
    ensure      => $service_ensure,
    enable      => $service_enable,
    hasrestart  => $service_hasrestart,
    hasstatus   => $service_hasstatus,
    require     => File['/etc/init.d/phd'],
    subscribe   => [
      Vcsrepo["${base_dir}/libphutil"],
      Vcsrepo["${base_dir}/phabricator"],
      File["${base_dir}/phabricator/conf/local/local.json"]
    ]
  }
}