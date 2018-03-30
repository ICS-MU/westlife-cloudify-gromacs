class gromacs::portal::config {
  # defaults 
  Ini_setting {
    path    => "${::gromacs::portal::code_dir}/data/gmx_serverconf.ini",
    section => 'server_settings',
    notify  => Exec['config_server.sh'],
  }

  Exec {
    path => '/bin:/usr/bin:/sbin:/usr/sbin',
  }

  # GROMACS data directory
  $_ensure_dir = $gromacs::portal::ensure ? {
    present => directory,
    default => $gromacs::portal::ensure
  }

  file { $gromacs::portal::data_dir:
    ensure => $_ensure_dir,
    force  => true,
    mode   => '0777',
  }

  if ($gromacs::portal::ensure == 'present') {
    File[$gromacs::portal::data_dir] {
      owner => $::apache::user,
      group => $::apache::group,
    }

    # server settings
    ini_setting { 'gmx_serverconf.ini-STR_BASEDIR':
      setting => 'STR_BASEDIR',
      value   => $gromacs::portal::code_dir,
    }

    ini_setting { 'gmx_serverconf.ini-STR_GRID_POOL_DIR':
      setting => 'STR_GRID_POOL_DIR',
      value   => $gromacs::portal::data_dir,
    }

    ini_setting { 'gmx_serverconf.ini-STR_SERVER_URL':
      setting => 'STR_SERVER_URL',
      value   => $gromacs::portal::_server_url,
    }

    ini_setting { 'gmx_serverconf.ini-STR_SERVER_CGI':
      setting => 'STR_SERVER_CGI',
      value   => $gromacs::portal::_server_cgi,
    }

    ini_setting { 'gmx_serverconf.ini-STR_ADMIN_EMAIL':
      setting => 'STR_ADMIN_EMAIL',
      value   => $gromacs::portal::admin_email,
    }

    # easy user options
    ini_setting { 'gmx_serverconf.ini-INT_USER_EASY_STORETIME':
      section => 'User permission setting',
      setting => 'INT_USER_EASY_STORETIME',
      value   => $gromacs::portal::user_storetime,
    }

    ini_setting { 'gmx_serverconf.ini-INT_USER_EASY_MAXJOB':
      section => 'User permission setting',
      setting => 'INT_USER_EASY_MAXJOB',
      value   => $gromacs::portal::user_maxjob,
    }

    ini_setting { 'gmx_serverconf.ini-FLT_USER_EASY_SIMTIME':
      section => 'User permission setting',
      setting => 'FLT_USER_EASY_SIMTIME',
      value   => $gromacs::portal::user_simtime,
    }

    # gromacs options
    ini_setting { 'gmx_serverconf.ini-INT_GROMACS_CPU_NR':
      section => 'gromacs_options',
      setting => 'INT_GROMACS_CPU_NR',
      value   => $gromacs::portal::gromacs_cpu_nr,
    }

    # configure gromacs
    exec { 'config_server.sh':
      command   => "${::gromacs::portal::code_dir}/config_server.sh",
      cwd       => $::gromacs::portal::code_dir,
      logoutput => true,
      require   => File[$gromacs::portal::data_dir],
    }

    # fix permission
    $_find_type = "find ${::gromacs::portal::code_dir} -type"

    exec { 'fix-gromacs-portal-dirs':
      command => "${_find_type} d -exec chmod g+rwx {} \\;",
      require => Exec['config_server.sh'],
    }

    exec { 'fix-gromacs-portal-files':
      command => "${_find_type} f -exec chmod g+rw {} \\;",
      require => Exec['config_server.sh'],
    }

    exec { 'fix-gromacs-portal-owner':
      command => "chown -R ${::apache::user}:${::apache::group} ${::gromacs::portal::code_dir}",
      require => Exec['config_server.sh'],
    }
  }

  # job manager
  cron { 'gmx_gridmanager':
    ensure      => $gromacs::portal::ensure,
    command     => "test -r ${gromacs::portal::data_dir} && ( cd ${gromacs::portal::data_dir} && /var/www/gromacs/cron/gmx_gridmanager.sh &>>/tmp/gmx_gridmanager.log )",
    minute      => '1-59/2', #odd
    user        => $gromacs::user::user_name,
    environment => "MAILTO=${::gromacs::portal::admin_email}",
  }

  cron { 'gmx_jobcontroller':
    ensure      => $gromacs::portal::ensure,
    command     => "cd ${gromacs::portal::code_dir}/cron/ && ( ./gmx_jobcontroller.sh &>>/tmp/gmx_jobcontroller.log; PYTHONPATH=../spyder/gmx/ ./gmx_stats &>>/tmp/gmx_stats )",
    minute      => '*/2', #even
    user        => $gromacs::user::user_name,
    environment => "MAILTO=${gromacs::portal::admin_email}",
  }

  cron { 'gmx_postprocessor':
    ensure      => $gromacs::portal::ensure,
    command     => "cd ${gromacs::portal::code_dir}/cron/ && ./gmx_postprocessor.sh &>>/tmp/gmx_postprocessor.log",
    minute      => '*/5',
    user        => $gromacs::user::user_name,
    environment => "MAILTO=${gromacs::portal::admin_email}",
  }

  if ($gromacs::portal::ensure == 'present') {
    File[$gromacs::portal::data_dir] -> Cron['gmx_gridmanager']

  } else {
    Cron['gmx_gridmanager']   -> User[$gromacs::user::user_name]
    Cron['gmx_jobcontroller'] -> User[$gromacs::user::user_name]
    Cron['gmx_postprocessor'] -> User[$gromacs::user::user_name]
  }
}
