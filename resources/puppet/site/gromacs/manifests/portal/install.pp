class gromacs::portal::install {
  # Apache
  $_apache_package_ensure = $gromacs::portal::ensure ? {
    present => installed,
    default => purged,
  }

  $_apache_service_ensure = $gromacs::portal::ensure ? {
    present => running,
    default => stopped,
  }

  $_apache_service_enable = $gromacs::portal::ensure ? {
    present => true,
    default => false
  }

  class { '::apache':
    mpm_module     => 'prefork',
    default_vhost  => false,
    package_ensure => $_apache_package_ensure,
    service_ensure => $_apache_service_ensure,
    service_enable => $_apache_service_enable,
  }

  if ($gromacs::portal::ensure == 'present') {
    ensure_packages($::gromacs::portal::packages)

    contain ::apache::mod::php
    contain ::apache::mod::auth_mellon

    $_custom_fragment = inline_template('
  <Directory "<%= scope["gromacs::portal::code_dir"] %>/cgi">
    Options +ExecCGI
    AddHandler cgi-script .cgi
  </Directory>

<% if scope["gromacs::portal::auth_enabled"] == true -%>
  <Location "/" >
    AuthType Mellon
    MellonEnable "auth"
    Require valid-user

    MellonSPPrivateKeyFile /etc/httpd/mellon/service.key
    MellonSPCertFile       /etc/httpd/mellon/service.cert
    MellonSPMetadataFile   /etc/httpd/mellon/service.xml

    # https://auth.west-life.eu/proxy/saml2/idp/metadata.php
    MellonIdPMetadataFile  /etc/httpd/mellon/idp-metadata.xml

    # Mapping of attribute names to something readable
    MellonSetEnv "name" "urn:oid:2.16.840.1.113730.3.1.241"
    MellonSetEnv "mail" "urn:oid:0.9.2342.19200300.100.1.3"
    MellonSetEnv "eppn" "urn:oid:1.3.6.1.4.1.5923.1.1.1.6"
    MellonSetEnv "entitlement" "urn:oid:1.3.6.1.4.1.5923.1.1.1.7"
    MellonSetEnv "eduPersonUniqueId" "urn:oid:1.3.6.1.4.1.5923.1.1.1.13"
  </Location>

  <LocationMatch "^/+results/+[0-9]+/+[^/]+\.(tpr|cpt)$">
    MellonEnable "off"
    Satisfy any
  </LocationMatch>
<% end -%>
')

    #TODO: uninstall
    if $gromacs::portal::auth_enabled {
      file { '/etc/httpd/mellon':
        ensure  => directory,
        mode    => '0750',
        owner   => 'apache',
        group   => 'apache',
        require => Package['httpd'],
      }

      file { '/etc/httpd/mellon/idp-metadata.xml':
        ensure => file,
        mode   => '0640',
        owner  => 'apache',
        group  => 'apache',
        source => 'puppet:///modules/gromacs/idp-metadata.xml',
        notify => Class['apache::service'],
      }

      # user provided service keys/certs
      if length($gromacs::portal::auth_service_key_b64) > 0 {
        file { '/etc/httpd/mellon/service.key':
          ensure  => file,
          mode    => '0640',
          owner   => 'apache',
          group   => 'apache',
          content => base64('decode', $gromacs::portal::auth_service_key_b64),
          notify  => Class['apache::service'],
        }
      } else {
        fail('Missing $gromacs::portal::auth_service_key_b64')
      }

      if length($gromacs::portal::auth_service_cert_b64) > 0 {
        file { '/etc/httpd/mellon/service.cert':
          ensure  => file,
          mode    => '0640',
          owner   => 'apache',
          group   => 'apache',
          content => base64('decode', $gromacs::portal::auth_service_cert_b64),
          notify  => Class['apache::service'],
        }
      } else {
        fail('Missing $gromacs::portal::auth_service_cert_b64')
      }

      if length($gromacs::portal::auth_service_meta_b64) > 0 {
        file { '/etc/httpd/mellon/service.xml':
          ensure  => file,
          mode    => '0640',
          owner   => 'apache',
          group   => 'apache',
          content => base64('decode', $gromacs::portal::auth_service_meta_b64),
          notify  => Class['apache::service'],
        }
      } else {
        fail('Missing $gromacs::portal::auth_service_meta_b64')
      }
    }

    apache::vhost { 'http':
      ensure          => present,
      servername      => $gromacs::portal::servername,
      port            => 80,
      docroot         => $::gromacs::portal::code_dir,
      manage_docroot  => true,
      docroot_owner   => 'apache',
      docroot_group   => 'apache',
      custom_fragment => $_custom_fragment,
    }

    # SSL via Let's Encrypt
    if $::gromacs::portal::ssl_enabled {
      class { '::letsencrypt':
        email               => $::gromacs::portal::admin_email,
        unsafe_registration => true,
      }

      letsencrypt::certonly { $gromacs::portal::servername:
        plugin               => 'standalone',
        manage_cron          => true,
        cron_before_command  => '/bin/systemctl stop httpd.service',
        cron_success_command => '/bin/systemctl restart httpd.service',
        suppress_cron_output => true,
        before               => ::Apache::Vhost['https'],
      }

      apache::vhost { 'https':
        ensure          => present,
        servername      => $gromacs::portal::servername,
        port            => 443,
        docroot         => $::gromacs::portal::code_dir,
        manage_docroot  => false,
        docroot_owner   => 'apache',
        docroot_group   => 'apache',
        ssl             => true,
        ssl_cert        => "/etc/letsencrypt/live/${gromacs::portal::servername}/cert.pem",
        ssl_chain       => "/etc/letsencrypt/live/${gromacs::portal::servername}/chain.pem",
        ssl_key         => "/etc/letsencrypt/live/${gromacs::portal::servername}/privkey.pem",
        custom_fragment => $_custom_fragment,
      }

      # redirect http->https
      Apache::Vhost['http'] {
        redirect_dest => "${::gromacs::portal::_server_url}/"
      }
    }

    #TODO: vcsrepo
    $_portal_arch = '/tmp/gromacs-portal.tar.gz'

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
  } elsif ($ensure = 'absent') {
    file { $gromacs::portal::code_dir:
      ensure => absent,
      force  => true,
      backup => false,
    }
  }
}
