class torque::mom (
  String  $ensure       = $torque::params::ensure,
  Array   $packages     = $torque::params::mom_packages,
  String  $inst_package = $torque::params::mom_inst_package,
  Boolean $export_node  = $torque::params::mom_export_node, #TODO
  String  $service      = $torque::params::mom_service,
  String  $server_name  = $torque::params::server_name
) inherits torque::params {

  contain torque::mom::install
  contain torque::mom::config
  contain torque::mom::service

  case $ensure {
    present: {
      Class['torque::mom::install']
        -> Class['torque::mom::config']
        ~> Class['torque::mom::service']
    }

    absent: {
      Class['torque::mom::service']
        -> Class['torque::mom::config']
        -> Class['torque::mom::install']
    }

    default: {
      fail("Invalid ensure state: ${ensure}")
    }
  }
}
