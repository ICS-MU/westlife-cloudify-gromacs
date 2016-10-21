class cuda::params {
  $repo_manage = true
  $repo_rooturl = 'http://developer.download.nvidia.com/compute/cuda/repos'
  $package_runtime = 'cuda-runtime'
  $package_toolkit = 'cuda-toolkit'
  $install_runtime = true
  $install_toolkit = true

  case $::operatingsystem {
    'redhat','centos','scientific','oraclelinux': {
      $repo_class = '::cuda::repo::rhel'
      $repo_baseurl = "${repo_rooturl}/rhel${::operatingsystemmajrelease}/${::architecture}"
      $repo_enabled = 1
      $repo_gpgcheck = 1
      $repo_gpgkey = '/etc/pki/rpm-gpg/RPM-GPG-KEY-cuda'
      $repo_gpgkey_source = 'puppet:///modules/cuda/7fa2af80.pub'
    }

    default: {
      fail("Unsupported OS: ${::operatingsystem}")
    }
  }
}
