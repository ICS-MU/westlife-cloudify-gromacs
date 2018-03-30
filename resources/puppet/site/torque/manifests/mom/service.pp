class torque::mom::service {
  $_ensure = $torque::mom::ensure == present

  service { $torque::mom::service:
    ensure  => $_ensure,
    enable  => $_ensure,
  }
}
