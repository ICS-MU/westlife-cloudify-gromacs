include ::westlife::nofirewall

if ($::cloudify_ctx_type == 'node-instance') or
   ($::cloudify_ctx_operation_name in ['establish', 'unlink'])
{
  include ::torque::scheduler
  include ::torque::server

  $facts.each |String $key, $value| {
    if $key =~ /^torque_node_(.*)$/ {
      $_id = $1

      if ($::cloudify_ctx_operation_name == 'unlink') and
        ($_id == $::cloudify_ctx_remote_instance_id)
      {
        warning("Skipping unlinked torque node: ${value['name']}")

      } else {
        warning("Torque node: ${value['name']} ${value['procs']}")

        ::torque::mom::node { $value['name']:
          ensure      => 'present',
          np          => $value['procs'],
          ntype       => 'cluster',
          properties  => 'num_node_boards=1',
          server_name => 'localhost',
          membership  => inclusive,
          provider    => 'parsed',
        }
      }
    }
  }

  ::torque::qmgr::attribute { 'server scheduler_iteration':
    object => 'server',
    key    => 'scheduler_iteration',
    value  => '30',
  }

  ::torque::qmgr::attribute { 'server scheduling':
    object => 'server',
    key    => 'scheduling',
    value  => 'true',
  }
  
  ::torque::qmgr::attribute { 'server keep_completed':
    object => 'server',
    key    => 'keep_completed',
    value  => '86400',
  }
  
  ::torque::qmgr::attribute { 'server mom_job_sync':
    object => 'server',
    key    => 'mom_job_sync',
    value  => 'true',
  }

  ::torque::qmgr::attribute { 'server node_check_rate':
    object => 'server',
    key    => 'node_check_rate',
    value  => '30',
  }
  
  # queue batch
  ::torque::qmgr::object { 'queue batch':
    ensure      => 'present',
    object      => 'queue',
    object_name => 'batch',
  }
  
  ::torque::qmgr::attribute { 'queue batch queue_type':
    object      => 'queue',
    object_name => 'batch',
    key         => 'queue_type',
    value       => 'execution',
    require     => ::Torque::Qmgr::Object['queue batch'],
  }
  
  ::torque::qmgr::attribute { 'queue batch started':
    object      => 'queue',
    object_name => 'batch',
    key         => 'started',
    value       => 'true',
    require     => ::Torque::Qmgr::Object['queue batch'],
  }
  
  ::torque::qmgr::attribute { 'queue batch enabled':
    object      => 'queue',
    object_name => 'batch',
    key         => 'enabled',
    value       => 'true',
    require     => ::Torque::Qmgr::Object['queue batch'],
  }
  
  ::torque::qmgr::attribute { 'queue batch resources_default.walltime':
    object      => 'queue',
    object_name => 'batch',
    key         => 'resources_default.walltime',
    value       => '01:00:00',
    require     => ::Torque::Qmgr::Object['queue batch'],
  }
  
  ::torque::qmgr::attribute { 'queue batch resources_default.nodes':
    object      => 'queue',
    object_name => 'batch',
    key         => 'resources_default.nodes',
    value       => '1',
    require     => ::Torque::Qmgr::Object['queue batch'],
  }
  
  ::torque::qmgr::attribute { 'server default_queue':
    object   => 'server',
    key      => 'default_queue',
    value    => 'batch',
    require  => ::Torque::Qmgr::Object['queue batch'],
  }

} elsif ($::cloudify_ctx_type == 'relationship-instance') {
  ctx { 'torque_server_name':
    value => $::fqdn,
    side  => 'source',
  }

} else {
  fail('Standalone execution')
}
