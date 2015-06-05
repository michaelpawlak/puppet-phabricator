class phabricator::install::repos inherits ::phabricator::install {
  # pull down the arcanist repo
  vcsrepo { "${base_dir}/arcanist":
    ensure    => latest,
    provider  => git,
    source    => 'git://github.com/facebook/arcanist.git',
    owner     => $user,
    group     => $group,
    revision  => $arcanist_revision,
    require   => Class['php']
  }

  # pull down the libphutil repo
  vcsrepo { "${base_dir}/libphutil":
    ensure    => latest,
    provider  => git,
    source    => 'git://github.com/facebook/libphutil.git',
    owner     => $user,
    group     => $group,
    revision  => $libphutil_revision,
    require   => Class['php'],
    notify    => Exec['build_xhpast'],
  }

  # pull down the phabricator repo
  vcsrepo { "${base_dir}/phabricator":
    ensure    => latest,
    provider  => git,
    source    => 'git://github.com/facebook/phabricator.git',
    owner     => $user,
    group     => $group,
    revision  => $phabricator_revision,
    require   => Class['php'],
  }

  # build xhpast
  exec { 'build_xhpast':
    command   => "${base_dir}/libphutil/scripts/build_xhpast.sh",
    logoutput => true,
    path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    subscribe => Vcsrepo["${base_dir}/libphutil"]
  }
}