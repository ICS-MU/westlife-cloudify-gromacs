class gromacs::params {
  $version = '5.1.4'

  $user_name = 'gromacs'
  $user_id = undef
  $user_groups = []
  $user_shell = '/bin/bash'
  $user_home = undef
  $user_system = true

  $group_name = 'gromacs'
  $group_id = undef
  $group_system = true

  $public_key = undef
  $private_key_b64 = undef

  $portal_code_dir = '/var/www/gromacs'
  $portal_data_dir = '/data/gromacs'
  $portal_server_url = undef  #depends on $portal_enable_ssl
  $portal_server_cgi = undef
  $portal_admin_email = 'root@localhost'
  $portal_gromacs_cpu_nr = 8

  $portal_servername = $::fqdn
  $portal_ssl_enabled = true

  $portal_auth_enabled = false
  $portal_auth_service_key_b64 = undef
  $portal_auth_service_cert_b64 = undef
  $portal_auth_service_meta_b64 = undef
  $portal_dyndns_enabled = false
  $portal_dyndns_hostname = undef
  $portal_dyndns_server = undef
  $portal_dyndns_login = undef
  $portal_dyndns_password = undef
  $portal_dyndns_ssl = 'yes'

  case $::operatingsystem {
    'redhat','centos','scientific','oraclelinux': { #TODO
      case $::operatingsystemmajrelease {
        '7': {
          if ($::has_nvidia_gpu == true) {
            $prebuilt_suffix = '-cuda70.el7'
          } elsif ('avx2' in $::cpu_flags) {
            $prebuilt_suffix = '-avx2.el7'
          } elsif ('avx' in $::cpu_flags) {
            $prebuilt_suffix = '-avx.el7'
          } else {
            $prebuilt_suffix = '-el7'
          }

          $packages = ['openmpi-devel', 'bc', 'wget', 'mailx']
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
