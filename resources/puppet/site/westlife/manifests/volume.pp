class westlife::volume (
  $device,
  $fstype,
  $mountpoint
) {
  if $facts['disks'][delete($device, '/dev/')] {
    file { $mountpoint:
      ensure => directory,
    }

    mount { $mountpoint:
      ensure  => mounted,
      device  => $device,
      fstype  => $fstype,
      atboot  => true,
      options => 'defaults',
    }
  }
}
