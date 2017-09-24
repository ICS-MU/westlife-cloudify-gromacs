class torque::mom::config {
  #TODO
  file { '/var/spool/torque/mom_priv/config':
    ensure  => file,
    content => "
# Configuration for pbs_mom is managed by Puppet
\$pbsserver ${torque::mom::server_name}
\$mom_host ${::fqdn}
"
  }

  #TODO
  file { '/var/spool/torque/mom_priv/mom.layout':
    ensure  => file,
    content => 'nodes=1',
  }

  #TODO: hierarchy
}
