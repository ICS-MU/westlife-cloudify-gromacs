class westlife::volume (
  $mountpoint,
  $device = '',
  $fstype = 'ext4',
  $owner  = 'root',
  $group  = 'root',
  $mode   = '0777'
) {
  exec { "/usr/bin/mkdir ${mountpoint}":
    creates => $mountpoint,
  }

  $_ensure = delete($device, '/dev/') in $facts['disks'] ? {
    true    => mounted,
    default => absent,
  }

  mount { $mountpoint:
    ensure  => $_ensure,
    device  => $device,
    fstype  => $fstype,
    atboot  => true,
    options => 'defaults',
    require => Exec["/usr/bin/mkdir ${mountpoint}"],
    before  => File[$mountpoint],
  }

  # fix dir. permissions after mount
  file { $mountpoint:
    ensure => directory,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
  }
}
