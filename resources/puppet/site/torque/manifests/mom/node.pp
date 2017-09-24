define torque::mom::node (
  $ensure,
  $server_name,
  $np,
  $ntype,
  $membership,
  $provider,
  $num_node_boards = undef,
  $numa_board_str  = undef,
  $properties      = undef,
  $note            = undef
) {
  torque_node { $name:
    ensure          => $ensure,
    server_name     => $server_name,
    np              => $np,
    num_node_boards => $num_node_boards,
    numa_board_str  => $numa_board_str,
    ntype           => $ntype,
    properties      => $properties,
    note            => $note,
    membership      => $membership,
    provider        => $provider,
    notify          => Class['torque::server::service'],
  }
}
