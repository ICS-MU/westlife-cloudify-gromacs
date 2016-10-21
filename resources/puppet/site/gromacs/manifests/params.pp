class gromacs::params {
  $code_dir = '/var/www/gromacs'
  $data_dir = '/data/gromacs'
  $server_url = "http://${::fqdn}"
  $server_cgi = "http://${::fqdn}/cgi/"
  $admin_email = 'root@localhost'

  case $::operatingsystem {
    'redhat','centos','scientific','oraclelinux': { #TODO
      $packages = ['python2-crypto']
    }

    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
}
