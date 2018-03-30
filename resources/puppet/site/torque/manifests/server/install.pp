class torque::server::install {
  contain systemd

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

  if ($torque::server::ensure == present) {
    exec { '/tmp/.torque-server/install.sh --install':
      require => File['/tmp/.torque-server/install.sh'],
      creates => '/usr/local/sbin/pbs_server',
    }

    ensure_packages($torque::server::packages)

    $_ensure = $torque::server::ensure ? {
      present => file,
      default => absent,
    }

    file { '/usr/lib/systemd/system/pbs_sched.service':
      ensure => $_ensure,
      mode   => '0644',
      source => 'puppet:///modules/torque/pbs_sched.service',
      notify => Class['systemd'],
    }
  } elsif ($torque::server::ensure == absent) {
    exec { 'torque::server::install-uninstall':
      cwd     => '/',
      command => '/bin/bash -c "/tmp/.torque-server/install.sh --listfiles | xargs -n1 rm -rf"',
      onlyif  => '/bin/test -f /usr/local/sbin/pbs_server',
      require => File['/tmp/.torque-server/install.sh'],
    }
  }
}
