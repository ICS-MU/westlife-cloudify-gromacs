include ::gromacs::portal
include ::westlife::volume
include ::westlife::nofirewall

# Note: /scratch must be present on submit host
# before submitting on nodes via qsub -d /scratch
file { '/scratch':
  ensure  => link,
  target  => '/data',
  require => Class['::westlife::volume'],
}

# fix gromacs/apache group
exec { "usermod -a -G ${::gromacs::user::group_name} ${::apache::user}":
  unless  => "groups ${::apache::user} | grep -q ${::gromacs::user::group_name}",
  path    => '/bin:/usr/bin:/sbin:/usr/sbin',
  require => Class['::gromacs::portal'],
}

exec { "usermod -a -G ${::apache::group } ${::gromacs::user::user_name}":
  unless => "groups ${::gromacs::user::user_name } | grep -q ${::apache::group}",
  path   => '/bin:/usr/bin:/sbin:/usr/sbin',
  require => Class['::gromacs::portal'],
}

# dependency
Class['::westlife::volume'] ->
  Class['::gromacs::portal']
