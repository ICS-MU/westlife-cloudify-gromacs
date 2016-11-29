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
  file { $::gromacs::portal::data_dir:
    ensure => directory,
    owner  => $::apache::user,
    group  => $::apache::group,
    before => Exec['config_server.sh'],
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
    logoutput => true,
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

  # job manager
  cron { 'gmx_gridmanager':
    command     => 'cd /var/www/gromacs/server/temp && /var/www/gromacs/cron/gmx_gridmanager.sh',
    user        => $::gromacs::user::user_name,
    environment => 'MAILTO=holer@ics.muni.cz',
  }
}
