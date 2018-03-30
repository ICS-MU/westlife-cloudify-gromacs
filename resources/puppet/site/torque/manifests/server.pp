class torque::server (
  String  $ensure        = $torque::params::ensure,
  Array   $packages      = $torque::params::server_packages,
  String  $inst_package  = $torque::params::server_inst_package,
  String  $serverdb_file = $torque::params::serverdb_file,
  Hash    $nodes         = $torque::params::nodes,
  Boolean $purge_nodes   = $torque::params::server_purge_nodes,
  Array   $services      = $torque::params::server_services,
  String  $server_name   = $torque::params::server_name
) inherits torque::params {

  class { 'torque::client':
    ensure => $ensure,
  }

  contain torque::server::install
  contain torque::server::service

  case $ensure {
    present: {
      contain torque::server::config
      contain torque::server::live_config

      Class['torque::client']
        -> Class['torque::server::install']
        -> Class['torque::server::config']
        ~> Class['torque::server::service']
        -> Class['torque::server::live_config']
    }

    absent: {
      Class['torque::client']
        -> Class['torque::server::service']
        -> Class['torque::server::install']
    }

    default: {
      fail("Invalid ensure state: ${ensure}")
    }
  }
}
