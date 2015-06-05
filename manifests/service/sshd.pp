class phabricator::service::sshd inherits ::phabricator::service {
  if $manage_ssh {
    exec { "ln_sshd_phabricator":
      command => 'ln /usr/sbin/ssh /usr/sbin/sshd_phabricator'
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      creates => '/usr/sbin/sshd_phabricator',
      notify  => Service['sshd_phabricator']
    }

    exec { 'restart_ssh':
      command     => "${ssh_service_cmd} restart",
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      refreshonly => true,
      subscribe   => File_line['sshd_config_port']
    }

    service { 'sshd_phabricator':
      ensure      => 'started',
      enable      => true,
      hasrestart  => true,
      hasstatus   => true,
      require     => [
        File['/etc/ssh/sshd_config.phabricator'],
        File['/etc/pam.d/sshd_phabricator'],
        File['ln_sshd_phabricator']
      ]
    }
  }
}