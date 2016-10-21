class gromacs (
  $packages    = $gromacs::params::packages,
  $code_dir    = $gromacs::params::code_dir,
  $data_dir    = $gromacs::params::data_dir,
  $server_url  = $gromacs::params::server_url,
  $server_cgi  = $gromacs::params::server_cgi,
  $admin_email = $gromacs::params::admin_email
) inherits gromacs::params {

  contain ::gromacs::install
  contain ::gromacs::config

  Class['::gromacs::install']
    -> Class['::gromacs::config']
}
