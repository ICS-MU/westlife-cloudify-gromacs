class torque::mom::config {
  $_ensure = $torque::mom::ensure ? {
    present => file,
    default => absent,
  }

  #TODO
  file { '/var/spool/torque/mom_priv/config':
    ensure  => $_ensure,
    content => "
# Configuration for pbs_mom is managed by Puppet
\$pbsserver ${torque::mom::server_name}
\$mom_host ${::fqdn}
"
  }

  #TODO
  file { '/var/spool/torque/mom_priv/mom.layout':
    ensure  => $_ensure,
    content => 'nodes=1',
  }

  #TODO: hierarchy
}
