class torque::server::config {
  exec { 'timeout --preserve-status 5 pbs_server -f -t create -D':
    path    => '/bin:/usr/bin:/sbin/:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    creates => $torque::server::serverdb_file,
  }

  resources { 'torque_node':
    purge  => $torque::server::purge_nodes,
  }  

  # collect virtual resources
  Torque_node <| server_name == $torque::server::server_name |>
  Torque::Mom::Node <| server_name == $torque::server::server_name |>

  # collect expoerted resources
  #Torque_node <<| server_name == $torque::server::server_name |>>
  #Torque::Mom::Node <<| server_name == $torque::server::server_name |>>

  # create node resources from provided hash
  ensure_resources(
    'torque_node',
    $torque::server::nodes,
    { 'ensure' => 'present', })
}
