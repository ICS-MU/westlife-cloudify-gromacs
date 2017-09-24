class torque::client::install {
  file { '/tmp/.torque-client':
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0700',
  }

  file { '/tmp/.torque-client/install.sh':
    ensure => file,
    source => $torque::client::inst_package,
    mode   => '0700',
  }

  exec { '/tmp/.torque-client/install.sh --install':
    require => File['/tmp/.torque-client/install.sh'],
    creates => '/usr/local/bin/qsub',
  }

  ensure_packages($torque::client::packages)
}
