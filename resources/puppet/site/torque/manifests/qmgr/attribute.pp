define torque::qmgr::attribute (
  $object,
  $key,
  $value,
  $object_name = '',
  $server_name = $torque::client::server_name
) {
  if ($object_name != '') {
    $_object_cpd = "${object} ${object_name}"
  } else {
    $_object_cpd = "${object}"
  }

  $_cmd = "set ${_object_cpd} ${key} = ${value}"
  $_exe = "qmgr -a -c '${_cmd}' ${server_name}"

  exec { $_exe:
    unless      => "qmgr -a -c 'print ${_object_cpd}' | grep -iq '${_cmd}'",
    path        => '/bin:/usr/bin:/usr/local/bin',
    environment => 'KRB5CCNAME=/dev/null',
    require     => Class['torque::client'],
  }

  if defined(Class['torque::server']) {
    Class['torque::server'] -> Exec[$_exe]
  }
}
