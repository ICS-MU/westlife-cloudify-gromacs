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

  if ($torque::mom::ensure == present) {
    ensure_packages($torque::mom::packages)

    exec { '/tmp/.torque-mom/install.sh --install':
      require => File['/tmp/.torque-mom/install.sh'],
      creates => '/usr/local/sbin/pbs_mom',
    }
  } elsif ($torque::mom::ensure == absent) {
    exec { 'torque::mom::install-uninstall':
      cwd     => '/',
      command => '/bin/bash -c "/tmp/.torque-mom/install.sh --listfiles | xargs -n1 rm -rf"',
      onlyif  => '/bin/test -f /usr/local/sbin/pbs_mom',
      require => File['/tmp/.torque-mom/install.sh'],
    }
  }
}
