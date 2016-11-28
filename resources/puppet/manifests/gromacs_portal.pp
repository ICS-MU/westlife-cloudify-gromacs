include ::gromacs::portal
include ::westlife::volume
include ::westlife::nofirewall

#class { '::cuda':
#  install_runtime => false,
#}

# dependency
Class['::westlife::volume'] ->
  Class['::gromacs::portal']
