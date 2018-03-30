class gromacs (
  $ensure          = $gromacs::params::ensure,
  $version         = $gromacs::params::version,
  $prebuilt_suffix = $gromacs::params::prebuilt_suffix,
  $packages        = $gromacs::params::packages,
  $base_dir        = $gromacs::params::base_dir
) inherits gromacs::params {

  unless defined(Class['gromacs::user']) {
    class { 'gromacs::user':
      ensure => $ensure,
    }
  }

  case $ensure {
    present: {
      ensure_packages($packages)

      #TODO
      file { '/tmp/gromacs.tar.xz':
        ensure => file,
        source => "puppet:///modules/gromacs/gromacs-${version}${prebuilt_suffix}.tar.xz",
      }

      archive { '/tmp/gromacs.tar.xz':
        extract      => true,
        extract_path => '/',
        creates      => "/${base_dir}",
        require      => Class['gromacs::user'],
      }
    }

    absent: {
      file { "/${base_dir}":
        ensure => absent,
        force  => true,
        backup => false,
      }
    } 

    default: {
      fail("Invalid ensure state: ${ensure}")
    }
  }
}
