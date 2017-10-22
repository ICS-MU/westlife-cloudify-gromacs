class gromacs::portal (
  $packages              = $gromacs::params::portal_packages,
  $code_dir              = $gromacs::params::portal_code_dir,
  $data_dir              = $gromacs::params::portal_data_dir,
  $server_url            = $gromacs::params::portal_server_url,
  $server_cgi            = $gromacs::params::portal_server_cgi,
  $admin_email           = $gromacs::params::portal_admin_email,
  $gromacs_cpu_nr        = $gromacs::params::portal_gromacs_cpu_nr,
  $servername            = $gromacs::params::portal_servername,
  $ssl_enabled           = $gromacs::params::portal_ssl_enabled,
  $auth_enabled          = $gromacs::praams::portal_auth_enabled,
  $auth_service_key_b64  = $gromacs::praams::portal_auth_service_key_b64,
  $auth_service_cert_b64 = $gromacs::praams::portal_auth_service_cert_b64,
  $auth_service_meta_b64 = $gromacs::praams::portal_auth_service_meta_b64,
  $dyndns_enabled        = $gromacs::params::portal_dyndns_enabled,
  $dyndns_hostname       = $gromacs::params::portal_dyndns_hostname,
  $dyndns_server         = $gromacs::params::portal_dyndns_server,
  $dyndns_login          = $gromacs::params::portal_dyndns_login,
  $dyndns_password       = $gromacs::params::portal_dyndns_password,
  $dyndns_ssl            = $gromacs::params::portal_dyndns_ssl
) inherits gromacs::params {

  $_proto = $ssl_enabled ? {
    true    => 'https',
    default => 'http'
  }

  if ($server_url) {
    $_server_url = $server_url
  } else {
    $_server_url = "${_proto}://${servername}"
  }

  if ($server_cgi) {
    $_server_cgi = $server_cgi
  } else {
    $_server_cgi = "${_server_url}/cgi/"
  }

  require ::gromacs::user
  contain ::gromacs::portal::install
  contain ::gromacs::portal::config

  Class['::gromacs::portal::install']
    -> Class['::gromacs::portal::config']

  if $dyndns_enabled {
    contain gromacs::portal::dyndns

    Class['gromacs::portal::dyndns']
      -> Class['gromacs::portal::install']
  }
}
