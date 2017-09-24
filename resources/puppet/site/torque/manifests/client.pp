class torque::client (
  Array  $packages         = $torque::params::client_packages,
  String $inst_package     = $torque::params::client_inst_package,
  String $server_name_file = $torque::params::server_name_file,
  String $server_name      = $torque::params::server_name,
  String $service          = $torque::params::client_service
) inherits torque::params {

#  require torque::munge
  contain torque::client::install
  contain torque::client::config
  contain torque::client::service

  Class['torque::client::install']
    -> Class['torque::client::config']
    ~> Class['torque::client::service']
}
