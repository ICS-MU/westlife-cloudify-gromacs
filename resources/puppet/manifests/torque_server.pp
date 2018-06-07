$_torque_server_ensure = $facts['cloudify_ctx_operation_name'] ? {
  delete  => absent,
  stop    => absent,
  default => present,
}

###

include ::westlife::nofirewall

# in the preconfigure relationship context, set Torque server FQDN
# on the Torque MOM side
if ($facts['cloudify_ctx_type'] == 'relationship-instance') and
   ($facts['cloudify_ctx_operation_name'] == 'preconfigure')
{
  ctx { 'torque_server_name':
    value => $facts['networking']['fqdn'],
    side  => 'source',
  }

} else {
  class { 'torque::server':
    ensure => $_torque_server_ensure,
  }

  if ($facts['cloudify_ctx_type'] == 'node-instance') and
     ($_torque_server_ensure == 'present')
  {
    torque::qmgr::attribute { 'server scheduler_iteration':
      object => 'server',
      key    => 'scheduler_iteration',
      value  => '30',
    }

    torque::qmgr::attribute { 'server scheduling':
      object => 'server',
      key    => 'scheduling',
      value  => 'true',
    }
  
    torque::qmgr::attribute { 'server keep_completed':
      object => 'server',
      key    => 'keep_completed',
      value  => '86400',
    }
  
    torque::qmgr::attribute { 'server mom_job_sync':
      object => 'server',
      key    => 'mom_job_sync',
      value  => 'true',
    }

    torque::qmgr::attribute { 'server node_check_rate':
      object => 'server',
      key    => 'node_check_rate',
      value  => '180',
    }

    torque::qmgr::attribute { 'server managers':
      object => 'server',
      key    => 'managers',
      value  => "root@${facts['networking']['fqdn']},cfy@${facts['networking']['fqdn']}",
    }
  
    # queue batch
    torque::qmgr::object { 'queue batch':
      ensure      => 'present',
      object      => 'queue',
      object_name => 'batch',
    }
  
    torque::qmgr::attribute { 'queue batch queue_type':
      object      => 'queue',
      object_name => 'batch',
      key         => 'queue_type',
      value       => 'execution',
      require     => Torque::Qmgr::Object['queue batch'],
    }
  
    torque::qmgr::attribute { 'queue batch started':
      object      => 'queue',
      object_name => 'batch',
      key         => 'started',
      value       => 'true',
      require     => Torque::Qmgr::Object['queue batch'],
    }
  
    torque::qmgr::attribute { 'queue batch enabled':
      object      => 'queue',
      object_name => 'batch',
      key         => 'enabled',
      value       => 'true',
      require     => Torque::Qmgr::Object['queue batch'],
    }
  
    torque::qmgr::attribute { 'queue batch resources_default.walltime':
      object      => 'queue',
      object_name => 'batch',
      key         => 'resources_default.walltime',
      value       => '01:00:00',
      require     => ::Torque::Qmgr::Object['queue batch'],
    }
  
    torque::qmgr::attribute { 'queue batch resources_default.nodes':
      object      => 'queue',
      object_name => 'batch',
      key         => 'resources_default.nodes',
      value       => '1',
      require     => ::Torque::Qmgr::Object['queue batch'],
    }
  
    torque::qmgr::attribute { 'server default_queue':
      object   => 'server',
      key      => 'default_queue',
      value    => 'batch',
      require  => ::Torque::Qmgr::Object['queue batch'],
    }
  }

  $facts.each |String $key, $value| {
    if $key =~ /^torque_node_(.*)$/ {
      $_id = $1

      if ($facts['cloudify_ctx_operation_name'] == 'unlink') and
         ($facts['cloudify_ctx_remote_instance_id'] == $_id)
      {
        warning("Skipping unlinked torque node: ${value['name']}")

      } else {
        warning("Torque node: ${value['name']} ${value['procs']}")

        torque::mom::node { $value['name']:
          ensure          => 'present',
          np              => $value['procs'],
          ntype           => 'cluster',
#          num_node_boards => 1,
          server_name     => 'localhost',
          membership      => inclusive,
          provider        => 'parsed',
        }
      }
    }
  }
} 
