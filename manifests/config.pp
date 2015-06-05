# == Class: phabricator::config
#
# This module manages Phabricator configuration.
#
# === Parameters
#
# [*base_dir*]
# [*environment*]
# [*user*]
# [*group*]
#
# === Variables
#
# === Examples
#
class phabricator::config inherits ::phabricator {
  # setup the local.json config file
  file { "${base_dir}/phabricator/conf/local/local.json":
    ensure  => file,
    owner   => $user,
    group   => $group,
    content => template('phabricator/config.json.erb'),
    require => Vcsrepo["${base_dir}/phabricator"],
    notify  => [
      Exec['storage-upgrade']
      Service['phd']
    ]
  }

  sudo::conf { "${vcs_user}_ssh_repo":
    content   => $sudo_conf_content,
    priority  => 60
  }

  file_line { 'ignore_requiretty_vcs_user':
    path  => $::sudo::config_file,
    line  => "Defaults:${vcs_user} !requiretty"
  }

  if $manage_ssh {
    file_line { 'sshd_config_port':
      path    => '/etc/ssh/sshd_config',
      line    => "Port ${ssh_access_port}",
      match   => '^(#Port|Port).*',
      notify  => [
        Service['sshd_phabricator'],
        Exec['restart_ssh']
      }
    }

    file { '/etc/ssh/sshd_config.phabricator':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => template('phabricator/sshd_config.erb'),
      notify  => Service['sshd_phabricator']
    }

    if $::osfamily == 'Debian' {
      file { '/etc/default/ssh_phabricator':
        ensure  => 'file',
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template('gitolite/debian.d/default_ssh.erb'),
        require => File['/etc/init.d/sshd_phabricator'],
        notify  => Service['sshd_phabricator']
      }

      file { '/etc/init/sshd_phabricator':
        ensure  => 'file',
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template('gitolite/debian.d/init_ssh_conf.erb'),
        require => File['/etc/default/ssh_phabricator'],
        notify  => Service['sshd_phabricator']
    }

    file { '/etc/init.d/sshd_phabricator':
      ensure  => 'file',
      mode    => '0755',
      owner   => 'root',
      group   => 'root',
      content => template("gitolite/${os_template_dir}/sshd_init.erb"),
      require => File['/usr/sbin/sshd_phabricator'],
      notify  => Service['sshd_phabricator']
    }

    file { '/etc/pam.d/sshd_phabricator':
      ensure  => 'file',
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => template("gitolite/${os_template_dir}/pam_sshd.erb"),
      notify  => Service['sshd_phabricator']
    }
  }
}
