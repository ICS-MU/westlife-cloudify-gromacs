class gromacs::portal::install {
  ensure_packages($::gromacs::portal::packages)

  class { '::apache':
    mpm_module    => 'prefork',
    default_vhost => false,
  }

  require ::apache::mod::php

  ::apache::vhost { 'http':
    ensure          => present,
    port            => 80,
    docroot         => $::gromacs::portal::code_dir,
    manage_docroot  => true,
    docroot_owner   => 'apache',
    docroot_group   => 'apache',
    custom_fragment => "

  <Directory '${::gromacs::portal::code_dir}/cgi'>
    Options +ExecCGI
    AddHandler cgi-script .cgi
  </Directory>
",
  }

  #TODO: vcsrepo
  $_portal_arch = '/tmp/gromacs-porta.tar.gz'

  file { $_portal_arch:
    ensure => file,
    source => 'puppet:///modules/gromacs/private/gromacs-portal.tar.gz',
  }

  archive { $_portal_arch:
    extract      => true,
    extract_path => $::gromacs::portal::code_dir,
    creates      => "${::gromacs::portal::code_dir}/cgi",
    user         => $::apache::user,
    group        => $::apache::group,
    require      => Class['::apache'],
  }
}
