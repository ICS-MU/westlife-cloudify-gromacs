class westlife::postfix (
  $root_recipient    = '',
  $gromacs_recipient = ''
) {
  # External root recipient
  $_ensure_root = $root_recipient ? {
    ''      => absent,
    default => present,
  }

  mailalias { 'root':
    ensure    => $_ensure_root,
    recipient => $root_recipient,
    notify    => Exec['newaliases'],
  }

  # External gromacs recipient
  $_ensure_gromacs = $gromacs_recipient ? {
    ''      => absent,
    default => present,
  }

  mailalias { 'gromacs':
    ensure    => $_ensure_gromacs,
    recipient => $gromacs_recipient,
    notify    => Exec['newaliases'],
  }

  exec { 'newaliases':
    path        => '/bin:/usr/bin:/sbin/:/usr/sbin',
    refreshonly => true,
    require     => Class['postfix::server'],
  }

  class { 'postfix::server':
    service_restart => 'service postfix restart',
  }
}
