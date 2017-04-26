include ::westlife::volume
include ::westlife::nofirewall

if ($::cloudify_ctx_type == 'node-instance') {
  class { '::torque::mom':
    server_name => $::torque_server_name,
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
      value => '@1', # we want the node exclusively
      #value => "@${facts['processors']['count']}",
      side  => 'target',
    }
  }
} else {
  fail('Standalone execution')
}
