class gromacs::config {
  # GROMACS data directory
  file { $::gromacs::data_dir:
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    before => Exec['config_server.sh'],
  }

  # defaults for ini_setting
  Ini_setting {
    path    => "${::gromacs::code_dir}/data/gmx_serverconf.ini",
    section => 'server_settings',
    notify  => Exec['config_server.sh'],
  }

  # settings
  ini_setting { 'gmx_serverconf.ini-STR_BASEDIR':
    setting => 'STR_BASEDIR',
    value   => $::gromacs::code_dir,
  }

  ini_setting { 'gmx_serverconf.ini-STR_GRID_POOL_DIR':
    setting => 'STR_GRID_POOL_DIR',
    value   => $::gromacs::data_dir,
  }

  ini_setting { 'gmx_serverconf.ini-STR_SERVER_URL':
    setting => 'STR_SERVER_URL',
    value   => $::gromacs::server_url,
  }

  ini_setting { 'gmx_serverconf.ini-STR_SERVER_CGI':
    setting => 'STR_SERVER_CGI',
    value   => $::gromacs::server_cgi,
  }

  ini_setting { 'gmx_serverconf.ini-STR_ADMIN_EMAIL':
    setting => 'STR_ADMIN_EMAIL',
    value   => $::gromacs::admin_email,
  }

  # configure gromacs
  exec { 'config_server.sh':
    command   => "${::gromacs::code_dir}/config_server.sh",
    cwd       => $::gromacs::code_dir,
    path      => '/bin:/usr/bin:/sbin:/usr/sbin',
    logoutput => true,
  }

#  Cron {
#    user        => 'root',
#    environment => 'MAILTO=holer@ics.muni.cz',
#  }
#
#  cron { 'gromacs_script1':
#    command     => '/bin/true',
#    hour        => 4,
#    minute      => 4,
#  }
#
#  cron { 'gromacs_script2':
#    command     => '/bin/true',
#    hour        => 4,
#    minute      => 5,
#  }
#
#  cron { 'gromacs_script3':
#    command     => '/bin/true',
#    hour        => 4,
#    minute      => 5,
#  }
}
