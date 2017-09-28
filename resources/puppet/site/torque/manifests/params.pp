class torque::params {
  $server_name = 'localhost'
  $nodes = {}
  $mom_export_node = true
  $server_purge_nodes = true

  case $::operatingsystem {
    'redhat','centos','scientific','oraclelinux': {
      $mom_packages = []
      $mom_inst_package = 'puppet:///modules/torque/torque-package-mom-linux-x86_64.sh'
      $mom_service = 'pbs_mom'

      $client_packages = []
      $client_inst_package = 'puppet:///modules/torque/torque-package-clients-linux-x86_64.sh'
      $client_service = 'trqauthd'

      $server_packages = []
      $server_inst_package = 'puppet:///modules/torque/torque-package-server-linux-x86_64.sh'
      $server_name_file = '/var/spool/torque/server_name'
      $serverdb_file = '/var/spool/torque/server_priv/serverdb'
      $server_services  = ['pbs_sched', 'pbs_server']
    }

    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
}
