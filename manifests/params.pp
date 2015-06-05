# == Class: phabricator::params
#
# This module manages the default Phabricator parameters.
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
class phabricator::params {
  #
  # 1. General Settings
  # ==============================
  $user               = 'phabricator'
  $group              = 'phabricator'
  $vcs_user           = 'git'
  $sudo_conf_content  = "${vcs_user} ALL=(${user}) SETENV: NOPASSWD: /usr/bin/git-upload-pack, /usr/bin/git-receive-pack, /usr/bin/hg, /usr/bin/svnserve"

  #
  # 1. Database Settings
  # ==============================  
  $mysql_options  = {
    'mysqld'      => {
      'datadir'               => '/var/lib/mysql',
      'socket'                => '/var/lib/mysql/mysql.sock',
      'user'                  => 'mysql',
      'symbolic-links'        => '0',
      'bind-address'          => '0.0.0.0',
      'port'                  => '3306',
      'innodb_file_per_table' => '1',
      'log_error'             => '/var/log/mysql/mysqld.log',
      'pid-file'              => '/var/run/mysql/mysqld.pid',
      'sql_mode'              => 'STRICT_ALL_TABLES'
    },
    'mysqld_safe' => {
      'log_error'             => '/var/lib/mysql/mysql.sock',
      'socket'                => '/var/lib/mysql/run-cluster/mysql.sock',
      'sql_mode'              => 'STRICT_ALL_TABLES'
    },
    'client'      => {
      'socket'                => '/var/lib/mysql/mysql.sock'
    }
  }

  #
  # 2. Webserver Settings
  # ==============================
  $manage_nginx             = true
  $nginx_log_root           = '/var/log/nginx'
  $nginx_access_log         = "${nginx_log_root}/phabricator_access.log"
  $nginx_error_log          = "${nginx_log_root}/phabricator_error.log"
  $nginx_vhost_cfg_prepend  = {
    'charset'         => 'UTF-8',
    'gzip_comp_level' => '4',
    'gzip_proxied'    => 'any',
    'gzip_static'     => 'on',
    'gzip_types'      => 'application/javascript application/json application/rss+xml application/vnd.ms-fontobject application/xhtml+xml application/xml application/xml+rss application/x-font-opentype application/x-font-ttf application/x-javascript image/svg+xml image/x-icon text/css text/javascript text/plain text/xml',
    'gzip_vary'       => 'on',
    'tcp_nopush'      => 'on',
  }
  $nginx_fastcgi_param      = {
    'REDIRECT_STATUS'   => '200',
    'SCRIPT_FILENAME'   => '$document_root$fastcgi_script_name',
    'QUERY_STRING'      => '$query_string',
    'REQUEST_METHOD'    => '$request_method',
    'CONTENT_TYPE'      => '$content_type',
    'CONTENT_LENGTH'    => '$content_length',
    'SCRIPT_NAME'       => '$fastcgi_script_name',
    'GATEWAY_INTERFACE' => 'CGI/1.1',
    'SERVER_SOFTWARE'   => 'nginx/$nginx_version',
    'REMOTE_ADDR'       => '$remote_addr'
  }
  #
  # 3. PHP Settings
  # ==============================
  $php_settings     = {
    'date.timezone' => 'UTC'
  }
  $php_fpm_settings = {}
  $php_fpm_pools  = {
    'www' => {
      'listen'                => '127.0.0.1:9000',
      'catch_workers_output'  => 'yes',
      'env_value'             => {
        'PATH'          => '/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
      },
      'php_value'             => {
        'date.timezone' => 'UTC'
      }
    },
    'phabricator' => {
      'pm_status_path'        => '/status',
      'listen'                => '127.0.0.1:9001',
      'user'                  => $user,
      'group'                 => $group,
      'ping_path'             => '/ping',
      'catch_workers_output'  => 'yes',
      'env_value'             => {
        'PATH'          => '/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
      },
      'php_value'             => {
        'date.timezone' => 'UTC'
      }
    }
  }

  #
  # 4. OS Specific Settings
  # ==============================
  case $::osfamily {
    'RedHat': {
      $dependencies = ['mysql-devel', 'git', 'automake',
                       'gcc', 'gcc-c++', 'kernel-devel',
                       'httpd-devel', 'pcre-devel']
      $web_packages = ['ImageMagick', 'python-pygments']
      $php_extensions   = {
        'mysql' => {
          'settings'  => {
            'ensure'  => 'present'
          }
        },
        'apc' => {
          'provider'  => 'pecl',
          'settings'  => {
            'apc.stat'  => '0',
            'extension' => 'apc.so'
          }
        },
        'ldap'  => {
          'settings'  => {
            'extension' => 'ldap.so'
          }
        },
        'gd'  => {},
        'process' => {},
        'mbstring'  => {}
      }
      $ssh_service_cmd  = '/sbin/service sshd'
      $os_template_dir  = 'rhel.d'
    }
    'Debian': {
      $dependencies = ['libmysqlclient-dev', 'git-core', 'git',
                       'build-essential', 'libpcre3-dev']
      $web_packages = ['imagemagick', 'python-pygments']
      $php_extensions   = {
        'mysql' => {
          'settings'  => {
            'ensure'  => 'present'
          }
        },
        'apc' => {
          'provider'  => 'pecl',
          'settings'  => {
            'apc.stat'  => '0',
            'extension' => 'apc.so'
          }
        },
        'ldap'  => {
          'settings'  => {
            'extension' => 'ldap.so'
          }
        },
        'curl'  => {},
        'gd'  => {},
        'mbstring' => {}
      }
      $ssh_service_cmd  = '/usr/sbin/service ssh'
      $os_template_dir  = 'debian.d'
    }
  }
}
