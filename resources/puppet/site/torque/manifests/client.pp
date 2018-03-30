class torque::client (
  String $ensure           = $torque::params::ensure,
  Array  $packages         = $torque::params::client_packages,
  String $inst_package     = $torque::params::client_inst_package,
  String $logs_dir         = $torque::params::client_logs_dir,
  String $server_name_file = $torque::params::server_name_file,
  String $server_name      = $torque::params::server_name,
  String $service          = $torque::params::client_service
) inherits torque::params {

  contain torque::client::install
  contain torque::client::config
  contain torque::client::service

  case $ensure {
    present: {
      Class['torque::client::install']
        -> Class['torque::client::config']
        ~> Class['torque::client::service']
    }

    absent: {
      Class['torque::client::service']
        -> Class['torque::client::config']
        -> Class['torque::client::install']
    }

    default: {
      fail("Invalid ensure state: ${ensure}")
    }
  }
}
