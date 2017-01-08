class gromacs::portal (
  $packages    = $gromacs::params::portal_packages,
  $code_dir    = $gromacs::params::portal_code_dir,
  $data_dir    = $gromacs::params::portal_data_dir,
  $server_url  = $gromacs::params::portal_server_url,
  $server_cgi  = $gromacs::params::portal_server_cgi,
  $admin_email = $gromacs::params::portal_admin_email,
  $enable_ssl  = $gromacs::params::portal_enable_ssl
) inherits gromacs::params {

  require ::gromacs::user
  contain ::gromacs::portal::install
  contain ::gromacs::portal::config

  Class['::gromacs::portal::install']
    -> Class['::gromacs::portal::config']
}
