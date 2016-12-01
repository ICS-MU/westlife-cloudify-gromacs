class westlife::volume (
  $device,
  $fstype,
  $mountpoint,
  $owner = 'root',
  $group = 'root',
  $mode  = '0777'
) {
  if $facts['disks'][delete($device, '/dev/')] {
    exec { "/usr/bin/mkdir ${mountpoint}":
      creates => $mountpoint,
    }

    mount { $mountpoint:
      ensure  => mounted,
      device  => $device,
      fstype  => $fstype,
      atboot  => true,
      options => 'defaults',
      require => Exec["/usr/bin/mkdir ${mountpoint}"],
    }

    # fix dir. permissions after mount
    file { $mountpoint:
      ensure  => directory,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      require => Mount[$mountpoint],
    }
  }
}
