class phabricator::base inherits ::phabricator {
  # phabricator system user group
  group { $group:
    ensure  => present
  }

  # phabricator system user
  user { $user:
    comment   => 'Phabriator',
    home      => $base_dir,
    ensure    => present,
    shell     => '/bin/bash',
    password  => '*',
    gid       => $group,
    require   => Group[$group]
  }

  # vcs system user
  user { $vcs_user:
    comment   => 'VCS User',
    home      => $local_repo_path,
    ensure    => present,
    shell     => '/bin/bash',
    groups    => [$group],
    password  => '*'
  }

  # phabricator base directory
  file { $base_dir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755'
  }

  # phabricator base directory
  file { $local_repo_path:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0775'
  }

  # install dependencies
  ensure_packages($dependencies)
}