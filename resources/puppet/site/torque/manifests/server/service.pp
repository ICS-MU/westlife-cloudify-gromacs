class torque::server::service {
  $_ensure = $torque::server::ensure == present

  service { $torque::server::services:
    ensure  => $_ensure,
    enable  => $_ensure,
  }
}
