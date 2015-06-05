class phabricator::install::sshhook inherits ::phabricator::install {
  file { '/usr/libexec/phabricator-ssh-hook.sh':
    ensure  => file,
    owner   => 'root',
    group   => $group,
    mode    => '0755',
    content => template('phabricator/phabricator-ssh-hook.sh.erb')
  }
}