$ensure = $facts['cloudify_ctx_operation_name'] ? {
  delete  => absent,
  stop    => absent,
  default => present,
}

###

include westlife::volume
include westlife::nofirewall

if ($::cloudify_ctx_type == 'node-instance') {
  $_server_name = $facts['torque_server_name']

  if $_server_name and length($_server_name)>0 {
    class { 'torque::mom':
      ensure      => $ensure,
      server_name => $_server_name
    }
  } else {
    fail('Fact "torque_server_name" not set properly')
  }

} elsif ($::cloudify_ctx_type == 'relationship-instance') {
  #$_id = regsubst($::fqdn, '\.', '_', 'G')
  $_id = regsubst($::cloudify_ctx_instance_id, '\.', '_', 'G')

  if ($::cloudify_ctx_operation_name == 'unlink') {
    ctx { "torque_node_${_id}":
      value => '@null',
      side  => 'target',
    }

  } else {
    ctx { "torque_node_${_id}.name":
      value => $::fqdn,
      side  => 'target',
    }

    ctx { "torque_node_${_id}.procs":
      #value => '@1', # we want the node exclusively
      value => "@${facts['processors']['count']}",
      side  => 'target',
    }
  }
} else {
  fail('Standalone execution')
}
