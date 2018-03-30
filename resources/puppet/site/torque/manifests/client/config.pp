class torque::client::config {
  $_ensure = $torque::client::ensure ? {
    present => file,
    default => absent,
  }

  file { $torque::client::server_name_file:
    ensure  => $_ensure,
    content => $torque::client::server_name,
  }
}
