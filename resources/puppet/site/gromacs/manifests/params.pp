class gromacs::params {
  $version = '5.1.4'
  $portal_code_dir = '/var/www/gromacs'
  $portal_data_dir = '/data/gromacs'
  $portal_server_url = "http://${::fqdn}"
  $portal_server_cgi = "http://${::fqdn}/cgi/"
  $portal_admin_email = 'root@localhost'

  case $::operatingsystem {
    'redhat','centos','scientific','oraclelinux': { #TODO
       case $::operatingsystemmajrelease {
         '7': {
           $prebuilt_suffix = '-el7'
           $portal_packages = ['python2-crypto']
         }

         default: {
           fail("Unsupported OS: ${::operatingsystem} ${::operatingsystemmajrelease}")
         }
       }

    }

    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
}
