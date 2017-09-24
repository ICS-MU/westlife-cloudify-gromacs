class torque::server::service {
  service { $torque::server::services:
    ensure  => running,
    enable  => true,
  }
}
