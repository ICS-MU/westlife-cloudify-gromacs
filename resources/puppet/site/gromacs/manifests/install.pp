class gromacs::install {
  ensure_packages($::gromacs::packages)

  class { '::apache':
    mpm_module    => 'prefork',
    default_vhost => false,
  }

  require ::apache::mod::php

  ::apache::vhost { 'http':
    ensure          => present,
    port            => 80,
    docroot         => $::gromacs::code_dir,
    manage_docroot  => true,
    docroot_owner   => 'apache',
    docroot_group   => 'apache',
    custom_fragment => "

  <Directory '${::gromacs::code_dir}/cgi'>
    Options +ExecCGI
    AddHandler cgi-script .cgi
  </Directory>
",
  }

  #TODO: vcsrepo
  file { '/tmp/gromacs-portal.tar.gz':
    ensure => file,
    source => 'puppet:///modules/gromacs/private/gromacs-portal.tar.gz',
  }

  archive { '/tmp/gromacs-portal.tar.gz':
    extract         => true,
    extract_path    => $::gromacs::code_dir,
    creates         => "${::gromacs::code_dir}/cgi",
    user            => 'apache',
    group           => 'apache',
    require         => Class['::apache'],
  }
}
