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

  case $torque::client::ensure {
    present: {
      exec { 'torque::client::install-install':
        command => '/tmp/.torque-client/install.sh --install',
        require => File['/tmp/.torque-client/install.sh'],
        creates => '/usr/local/bin/qsub',
      }

      ensure_packages($torque::client::packages)
    }

    absent: {
      exec { 'torque::client::install-uninstall':
        cwd     => '/',
        command => '/bin/bash -c "/tmp/.torque-client/install.sh --listfiles | xargs -n1 rm -rf"',
        onlyif  => '/bin/test -f /usr/local/bin/qsub',
        require => File['/tmp/.torque-client/install.sh'],
      }

      file { $torque::client::logs_dir:
        ensure => absent,
        force  => true,
        backup => false,
      }
    }

    default: {
      fail("Invalid ensure state: ${ensure}")
    }
  }
}
