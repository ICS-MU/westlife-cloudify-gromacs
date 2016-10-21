class cuda::repo::rhel {
  yum::gpgkey { $::cuda::repo_gpgkey:
    source => $::cuda::repo_gpgkey_source,
  }

  yumrepo { 'cuda':
    enabled  => $::cuda::repo_enabled,
    descr    => 'cuda',
    baseurl  => $::cuda::repo_baseurl,
    gpgcheck => $::cuda::repo_gpgcheck,
    gpgkey   => "file:///${::cuda::repo_gpgkey}",
    require  => Yum::Gpgkey[$::cuda::repo_gpgkey],
  }
}
