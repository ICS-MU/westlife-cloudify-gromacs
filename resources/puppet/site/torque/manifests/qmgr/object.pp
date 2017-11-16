define torque::qmgr::object (
  $ensure,
  $object,
  $object_name,
  $server_name = $torque::client::server_name
) {
  Exec {
    path        => '/bin:/usr/bin:/usr/local/bin',
    environment => 'KRB5CCNAME=/dev/null',
    require     => Class['torque::client']
  }

  $_object_cpd = "${object} ${object_name}"

  case $ensure {
    'present': {
      $_exe = "qmgr -a -c 'create ${_object_cpd}' ${server_name}" 

      exec { $_exe:
        unless => "qmgr -a -c 'print ${_object_cpd}' ${server_name}",
      }

      if defined(Class['torque::server']) {
        Class['torque::server'] -> Exec[$_exe]
      }
    }

    'absent': {
      $_exe = "qmgr -a -c 'delete ${_object_cpd}' ${server_name}"

      exec { $_exe :
        onlyif => "qmgr -a -c 'print ${_object_cpd}' ${server_name}",
      }

      if defined(Class['torque::server']) {
        Class['torque::server'] -> Exec[$_exe]
      }
    }

    default: {
      fail("Invalid ensure state $ensure")
    }
  }

}
