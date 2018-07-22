class gromacs (
  $ensure       = $gromacs::params::ensure,
  $version      = $gromacs::params::version,
  $url_template = $gromacs::params::url_template,
  $build        = $gromacs::params::build,
  $packages     = $gromacs::params::packages,
  $base_dir     = $gromacs::params::base_dir
) inherits gromacs::params {

  unless defined(Class['gromacs::user']) {
    class { 'gromacs::user':
      ensure => $ensure,
    }
  }

  case $ensure {
    present: {
      ensure_packages($packages)

      file { '/tmp/.gromacs':
        ensure  => directory,
        purge   => true,
        recurse => true,
        mode    => '0700',
      }

      $_url = inline_epp($url_template)
      $_name = basename($_url)

      archive { "/tmp/.gromacs/${_name}":
        source       => $_url,
        extract      => true,
        extract_path => '/',
        creates      => "/${base_dir}",
        require      => File['/tmp/.gromacs'],
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
