$ensure = $facts['cloudify_ctx_operation_name'] ? {
  delete  => absent,
  stop    => absent,
  default => present,
}

###

class { 'gromacs':
  ensure => $ensure,
}

class { 'gromacs::portal':
  ensure => $ensure,
}

if ($ensure == 'present') {
  include westlife::volume
  include westlife::nofirewall
  include westlife::postfix

  # fix gromacs/apache group
  exec { "usermod -a -G ${gromacs::user::group_name} ${apache::user}":
    unless  => "groups ${apache::user} | grep -q ${gromacs::user::group_name}",
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    require => Class['gromacs::portal'],
  }

  exec { "usermod -a -G ${apache::group } ${gromacs::user::user_name}":
    unless => "groups ${gromacs::user::user_name } | grep -q ${apache::group}",
    path   => '/bin:/usr/bin:/sbin:/usr/sbin',
    require => Class['gromacs::portal'],
  }

  # dependency
  Class['westlife::volume']
    -> Class['gromacs::portal']
}
