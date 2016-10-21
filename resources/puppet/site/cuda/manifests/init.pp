class cuda (
  $release,
  $repo_manage        = $::cuda::params::repo_manage,
  $repo_class         = $::cuda::params::repo_class,
  $repo_baseurl       = $::cuda::params::repo_baseurl,
  $repo_enabled       = $::cuda::params::repo_enabled,
  $repo_gpgcheck      = $::cuda::params::repo_gpgcheck,
  $repo_gpgkey        = $::cuda::params::repo_gpgkey,
  $repo_gpgkey_source = $::cuda::params::repo_gpgkey_source,
  $package_runtime    = $::cuda::params::package_runtime,
  $package_toolkit    = $::cuda::params::package_toolkit,
  $install_runtime    = $::cuda::params::install_runtime,
  $install_toolkit    = $::cuda::params::install_toolkit
) inherits cuda::params {

  if $repo_manage and $repo_class {
    require $repo_class
  } 

  if $install_runtime {
    contain ::cuda::runtime

    if $install_toolkit {
      Class['::cuda::runtime'] ->
        Class['::cuda::toolkit']
    }
  }

  if $install_toolkit {
    contain ::cuda::toolkit
  }
}
