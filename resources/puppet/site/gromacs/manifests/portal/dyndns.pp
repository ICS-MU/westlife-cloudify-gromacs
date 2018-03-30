class gromacs::portal::dyndns {
  case $gromacs::portal::ensure {
    present: {
      #TODO: take IP address from the fact
      class { 'ddclient':
        host     => $gromacs::portal::dyndns_hostname,
        login    => $gromacs::portal::dyndns_login,
        password => $gromacs::portal::dyndns_password,
        server   => $gromacs::portal::dyndns_server,
        ssl      => $gromacs::portal::dyndns_ssl,
        protocol => 'dyndns2',
        use      => 'web',
        daemon   => '300 -pid=/var/run/ddclient/ddclient.pid', #HACK!
      }
    }

    absent: {
      service { 'ddclient':
        ensure  => stopped,
        enabled => false,
      }

      package { 'ddclient':
        ensure  => purged,
        require => Service['ddclient'],
      }
    }

    default: {
      fail("Invalid ensure state '${gromacs::portal::ensure}'")
    }
  }
}
