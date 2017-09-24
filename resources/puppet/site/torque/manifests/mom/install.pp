class torque::mom::install {
  file { '/tmp/.torque-mom':
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0700',
  }

  file { '/tmp/.torque-mom/install.sh':
    ensure => file,
    source => $torque::mom::inst_package,
    mode   => '0700',
  }

  exec { '/tmp/.torque-mom/install.sh --install':
    require => File['/tmp/.torque-mom/install.sh'],
    creates => '/usr/local/sbin/pbs_mom',
  }

  ensure_packages($torque::mom::packages)
}
