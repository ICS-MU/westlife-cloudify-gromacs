class torque::client::service {
  $_ensure = ($torque::client::ensure == present)

  service { $torque::client::service:
    ensure  => $_ensure,
    enable  => $_ensure,
  }
}
