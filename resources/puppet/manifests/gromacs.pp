$ensure = $facts['cloudify_ctx_operation_name'] ? {
  start   => present,
  delete  => absent,
  default => undef,
}

###

class { 'gromacs':
  ensure => $ensure,
}

# setup CUDA only if release specified
$cuda_release = lookup('cuda::release')
if (length("${cuda_release}")>0) and ($facts['has_nvidia_gpu']==true) {
  class { 'cuda':
    ensure => $ensure,
  }
}
