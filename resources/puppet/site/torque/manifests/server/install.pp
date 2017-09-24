class torque::server::install {
  file { '/tmp/.torque-server':
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0700',
  }

  file { '/tmp/.torque-server/install.sh':
    ensure => file,
    source => $torque::server::inst_package,
    mode   => '0700',
  }

  exec { '/tmp/.torque-server/install.sh --install':
    require => File['/tmp/.torque-server/install.sh'],
    creates => '/usr/local/sbin/pbs_server',
  }

  # scheduler service not packaged
  file { '/usr/lib/systemd/system/pbs_sched.service':
    ensure => file,
    mode   => '0644',
    source => 'puppet:///modules/torque/pbs_sched.service',
    notify => Exec['systemctl daemon-reload'],
  }

  exec { 'systemctl daemon-reload': 
    command     => '/usr/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  ensure_packages($torque::server::packages)
}
