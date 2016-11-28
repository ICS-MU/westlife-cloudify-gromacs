class gromacs::portal::config {
  # GROMACS data directory
  file { $::gromacs::portal::data_dir:
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    before => Exec['config_server.sh'],
  }

  # defaults for ini_setting
  Ini_setting {
    path    => "${::gromacs::portal::code_dir}/data/gmx_serverconf.ini",
    section => 'server_settings',
    notify  => Exec['config_server.sh'],
  }

  # settings
  ini_setting { 'gmx_serverconf.ini-STR_BASEDIR':
    setting => 'STR_BASEDIR',
    value   => $::gromacs::portal::code_dir,
  }

  ini_setting { 'gmx_serverconf.ini-STR_GRID_POOL_DIR':
    setting => 'STR_GRID_POOL_DIR',
    value   => $::gromacs::portal::data_dir,
  }

  ini_setting { 'gmx_serverconf.ini-STR_SERVER_URL':
    setting => 'STR_SERVER_URL',
    value   => $::gromacs::portal::server_url,
  }

  ini_setting { 'gmx_serverconf.ini-STR_SERVER_CGI':
    setting => 'STR_SERVER_CGI',
    value   => $::gromacs::portal::server_cgi,
  }

  ini_setting { 'gmx_serverconf.ini-STR_ADMIN_EMAIL':
    setting => 'STR_ADMIN_EMAIL',
    value   => $::gromacs::portal::admin_email,
  }

  # configure gromacs
  exec { 'config_server.sh':
    command   => "${::gromacs::portal::code_dir}/config_server.sh",
    cwd       => $::gromacs::portal::code_dir,
    path      => '/bin:/usr/bin:/sbin:/usr/sbin',
    logoutput => true,
  }

  cron { 'gmx_gridmanager':
    command     => 'cd /var/www/gromacs/server/temp && /var/www/gromacs/cron/gmx_gridmanager.sh',
    user        => 'apache',
    environment => 'MAILTO=holer@ics.muni.cz',
  }
}
