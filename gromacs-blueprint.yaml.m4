---

tosca_definitions_version: cloudify_dsl_1_3

description: >
  Gromacs portal setup via FedCloud OCCI and Puppet.

dnl *** From gromacs-inputs.yaml.m4 take only macros, drop regular texts.
divert(`-1')dnl
include(gromacs-inputs.yaml.m4)dnl
divert(`0')dnl

define(_NODE_SERVER_,         ifdef(`_CFM_',`gromacs.nodes.MonitoredServer',`gromacs.nodes.Server'))dnl
define(_NODE_HOSTPOOLSERVER_, ifdef(`_CFM_',`gromacs.nodes.MonitoredHostPoolServer',`gromacs.nodes.HostPoolServer'))dnl
define(_NODE_TORQUESERVER_,   ifdef(`_CFM_',`gromacs.nodes.MonitoredTorqueServer',`gromacs.nodes.TorqueServer'))dnl
define(_NODE_WEBSERVER_,      ifdef(`_CFM_',`gromacs.nodes.MonitoredWebServer', `gromacs.nodes.WebServer'))dnl
define(_NODE_SWCOMPONENT_,    ifdef(`_CFM_',`gromacs.nodes.MonitoredSoftwareComponent', `gromacs.nodes.SoftwareComponent'))dnl
define(_NAME_OLINNODE_,       ifelse(_PROVISIONER_,`hostpool',`olinNodeHostPool',`olinNode'))dnl
define(_NAME_WORKERNODE_,     ifelse(_PROVISIONER_,`hostpool',`workerNodeHostPool',`workerNode'))dnl
define(_NAME_TORQUESERVER_,   ifelse(_PROVISIONER_,`hostpool',`torqueServerHostPool',`torqueServer'))dnl

# Note: plugin/version installation for CFM handled
# in Makefile by target "cfm-plugins"
imports:
  - http://www.getcloudify.org/spec/cloudify/4.3/types.yaml
  - http://www.getcloudify.org/spec/diamond-plugin/1.3.1/plugin.yaml
  - https://raw.githubusercontent.com/cloudify-cosmo/cloudify-host-pool-plugin/1.5/plugin.yaml
  - https://raw.githubusercontent.com/ICS-MU/westlife-cloudify-occi-plugin/0.0.15/plugin.yaml
  - https://raw.githubusercontent.com/ICS-MU/westlife-cloudify-fabric-plugin/1.5.1.1/plugin.yaml
  - https://raw.githubusercontent.com/ICS-MU/westlife-cloudify-westlife-workflows/master/plugin.yaml
  - types/puppet.yaml
  - types/server.yaml
  - types/softwarecomponent.yaml
  - types/torqueserver.yaml
  - types/webserver.yaml

inputs:
  # OCCI
  occi_endpoint:
    default: ''
    type: string
  occi_auth:
    default: ''
    type: string
  occi_username:
    default: ''
    type: string
  occi_password:
    default: ''
    type: string
  occi_user_cred:
    default: ''
    type: string
  occi_ca_path:
    default: ''
    type: string
  occi_voms:
    default: False
    type: boolean

  # Host pool
  hostpool_service_url:
    default: ''
    type: string
  hostpool_username:
    default: 'root'
    type: string
  hostpool_private_key:
    default: ''
    type: string

  # contextualization
  cc_username:
    default: cfy
    type: string
  cc_public_key:
    type: string
  cc_private_key:
    type: string
  cc_data:
    default: {}

  # VM parameters
  olin_occi_os_tpl:
    type: string
  olin_occi_resource_tpl:
    type: string
  olin_occi_availability_zone:
    type: string
  olin_occi_network:
    type: string
  olin_occi_network_pool:
    type: string
  olin_occi_scratch_size:
    type: integer
  olin_hostpool_tags:
    default: []
  worker_occi_os_tpl:
    type: string
  worker_occi_resource_tpl:
    type: string
  worker_occi_availability_zone:
    type: string
  worker_occi_network:
    type: string
  worker_occi_network_pool:
    type: string
  worker_occi_scratch_size:
    type: integer
  worker_hostpool_tags:
    default: []

  # Application parameters
  cuda_release:
    type: string
  gromacs_portal_servername:
    type: string
  gromacs_portal_ssl_enabled:
    type: boolean
  gromacs_portal_gromacs_cpu_nr:
    type: integer
  gromacs_portal_admin_email:
    type: string
  gromacs_portal_gromacs_cpu_nr:
    type: integer
  gromacs_portal_user_storetime:
    type: integer
  gromacs_portal_user_maxjob:
    type: integer
  gromacs_portal_user_simtime:
    type: float
  gromacs_portal_dyndns_enabled:
    type: boolean
  gromacs_portal_dyndns_hostname:
    type: string
  gromacs_portal_dyndns_server:
    type: string
  gromacs_portal_dyndns_login:
    type: string
  gromacs_portal_dyndns_password:
    type: string
  gromacs_portal_dyndns_ssl:
    type: string
  gromacs_portal_auth_enabled:
    type: boolean
  gromacs_portal_auth_service_key_b64:
    type: string
  gromacs_portal_auth_service_cert_b64:
    type: string
  gromacs_portal_auth_service_meta_b64:
    type: string
  gromacs_user_public_key:
    type: string
  gromacs_user_private_key_b64:
    type: string

dsl_definitions:
  occi_configuration: &occi_configuration
    endpoint: { get_input: occi_endpoint }
    auth: { get_input: occi_auth }
    username: { get_input: occi_username }
    password: { get_input: occi_password }
    user_cred: { get_input: occi_user_cred }
    ca_path: { get_input: occi_ca_path }
    voms: { get_input: occi_voms }

  cloud_configuration: &cloud_configuration
    username: { get_input: cc_username }
    public_key: { get_input: cc_public_key }
    data: { get_input: cc_data }

  fabric_env: &fabric_env
    user: { get_input: cc_username }
    key: { get_input: cc_private_key }

  fabric_env_hostpool: &fabric_env_hostpool
    user: { get_input: hostpool_username }
    key: { get_input: hostpool_private_key }

  agent_configuration: &agent_configuration
    install_method: remote
    user: { get_input: cc_username }
    key: { get_input: cc_private_key }

  agent_configuration_hostpool: &agent_configuration_hostpool
    install_method: remote
    user: { get_input: hostpool_username }
    key: { get_input: hostpool_private_key }

  puppet_config: &puppet_config
    repo: 'https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm'
    package: 'puppet-agent'
    download: resources/puppet.tar.gz

  plugin_resources: &plugin_resources
    description: >
      Holds any archives that should be uploaded to the manager.
    default:
      - 'https://github.com/ICS-MU/westlife-cloudify-occi-plugin/releases/download/0.0.14/cloudify_occi_plugin-0.0.14-py27-none-linux_x86_64.wgn'

node_templates:

ifelse(_PROVISIONER_,`hostpool',`
  ### Predeployed nodes #######################################################

  # predeployed olin (frontend)
  olinNodeHostPool:
    type: _NODE_HOSTPOOLSERVER_
    properties:
      agent_config: *agent_configuration_hostpool
      fabric_env: *fabric_env_hostpool
      hostpool_service_url: { get_input: hostpool_service_url }
      filters:
        tags: { get_input: olin_hostpool_tags }

  gromacsPortalHostPool:
    type: _NODE_WEBSERVER_
    instances:
      deploy: 1
    properties:
      fabric_env: *fabric_env_hostpool
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/gromacs_portal.pp
          delete: manifests/gromacs_portal.pp
        hiera:
          gromacs::portal::servername: { get_input: gromacs_portal_servername }
          gromacs::portal::ssl_enabled: { get_input: gromacs_portal_ssl_enabled }
          gromacs::portal::admin_email: { get_input: gromacs_portal_admin_email }
          gromacs::portal::gromacs_cpu_nr: { get_input: gromacs_portal_gromacs_cpu_nr }
          gromacs::portal::user_storetime: { get_input: gromacs_portal_user_storetime }
          gromacs::portal::user_maxjob: { get_input: gromacs_portal_user_maxjob }
          gromacs::portal::user_simtime: { get_input: gromacs_portal_user_simtime }
          gromacs::portal::auth_enabled: { get_input: gromacs_portal_auth_enabled }
          gromacs::portal::auth_service_key_b64: { get_input: gromacs_portal_auth_service_key_b64 }
          gromacs::portal::auth_service_cert_b64: { get_input: gromacs_portal_auth_service_cert_b64 }
          gromacs::portal::auth_service_meta_b64: { get_input: gromacs_portal_auth_service_meta_b64 }
          gromacs::portal::dyndns_enabled: { get_input: gromacs_portal_dyndns_enabled }
          gromacs::portal::dyndns_hostname: { get_input: gromacs_portal_dyndns_hostname }
          gromacs::portal::dyndns_server: { get_input: gromacs_portal_dyndns_server }
          gromacs::portal::dyndns_login: { get_input: gromacs_portal_dyndns_login }
          gromacs::portal::dyndns_password: { get_input: gromacs_portal_dyndns_password }
          gromacs::portal::dyndns_ssl: { get_input: gromacs_portal_dyndns_ssl }
          gromacs::user::public_key: { get_input: gromacs_user_public_key }
          gromacs::user::private_key_b64: { get_input: gromacs_user_private_key_b64 }
          westlife::postfix::root_recipient: { get_input: gromacs_portal_admin_email }
          westlife::postfix::gromacs_recipient: { get_input: gromacs_portal_admin_email }
          #westlife::volume::device: /dev/vdc
          westlife::volume::fstype: ext4
          westlife::volume::mountpoint: /data
          westlife::volume::mode: "1777"
    relationships:
      - type: cloudify.relationships.contained_in
        target: olinNodeHostPool
      - type: gromacs.relationships.puppet.connected_to
        target: torqueServerHostPool

  torqueServerHostPool:
    type: _NODE_TORQUESERVER_
    instances:
      deploy: 1
    properties:
      fabric_env: *fabric_env_hostpool
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/torque_server.pp
          delete: manifests/torque_server.pp
    relationships:
      - type: cloudify.relationships.contained_in
        target: olinNodeHostPool

  # predeployed worker node
  workerNodeHostPool:
    type: _NODE_HOSTPOOLSERVER_
    properties:
      agent_config: *agent_configuration_hostpool
      fabric_env: *fabric_env_hostpool
      hostpool_service_url: { get_input: hostpool_service_url }
      filters:
        tags: { get_input: worker_hostpool_tags }

  torqueMomHostPool:
    type: _NODE_SWCOMPONENT_
    instances:
      deploy: 1
    properties:
      fabric_env: *fabric_env_hostpool
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/torque_mom.pp
          delete: manifests/torque_mom.pp
        hiera:
          westlife::volume::mountpoint: /scratch
          westlife::volume::mode: "1777"
    relationships:
      - type: cloudify.relationships.contained_in
        target: workerNodeHostPool
      - type: cloudify.relationships.depends_on
        target: gromacsHostPool
      - type: gromacs.relationships.puppet.connected_to
        target: torqueServerHostPool
        source_interfaces:
          cloudify.interfaces.relationship_lifecycle:
            postconfigure:
              inputs:
                manifest: manifests/torque_mom.pp     # nastaveni jmena/np mom na serveru
            unlink:
              inputs:
                manifest: manifests/torque_mom.pp     # zruseni np mom na serveru
        target_interfaces:
          cloudify.interfaces.relationship_lifecycle:
            preconfigure:
              inputs:
                manifest: manifests/torque_server.pp  # nastaveni ::torque_sever_name
            establish:
              inputs:
                manifest: manifests/torque_server.pp  # rekonfigurace serveru
            unlink:
              inputs:
                manifest: manifests/torque_server.pp  # rekonfigurace serveru

  gromacsHostPool:
    type: _NODE_SWCOMPONENT_
    instances:
      deploy: 1
    properties:
      fabric_env: *fabric_env_hostpool
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/gromacs.pp
          delete: manifests/gromacs.pp
        hiera:
          cuda::release: { get_input: cuda_release }
          gromacs::user::public_key: { get_input: gromacs_user_public_key }
          gromacs::user::private_key_b64: { get_input: gromacs_user_private_key_b64 }
    relationships:
      - type: cloudify.relationships.contained_in
        target: workerNodeHostPool

',_PROVISIONER_,`occi',`
  ### OCCI nodes #############################################################

  # olin (frontend)
  olinNode:
    type: _NODE_SERVER_
    properties:
      name: "Gromacs all-in-one server node"
      resource_config:
        os_tpl: { get_input: olin_occi_os_tpl }
        resource_tpl: { get_input: olin_occi_resource_tpl }
        availability_zone: { get_input: olin_occi_availability_zone }
        network: { get_input: olin_occi_network }
        network_pool: { get_input: olin_occi_network_pool }
      agent_config: *agent_configuration
      cloud_config: *cloud_configuration
      occi_config: *occi_configuration
      fabric_env: *fabric_env

  olinStorage:
    type: cloudify.occi.nodes.Volume
    properties:
      size: { get_input: olin_occi_scratch_size }
      availability_zone: { get_input: olin_occi_availability_zone }
      occi_config: *occi_configuration
    interfaces:
      cloudify.interfaces.lifecycle:
        delete:
          inputs:
            wait_finish: false
    relationships:
      - type: cloudify.occi.relationships.volume_contained_in_server
        target: olinNode
        target_interfaces:
          cloudify.interfaces.relationship_lifecycle:
            unlink:
              inputs:
                skip_action: true

  gromacsPortal:
    type: _NODE_WEBSERVER_
    instances:
      deploy: 1
    properties:
      fabric_env: *fabric_env
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/gromacs_portal.pp
        hiera:
          gromacs::portal::servername: { get_input: gromacs_portal_servername }
          gromacs::portal::ssl_enabled: { get_input: gromacs_portal_ssl_enabled }
          gromacs::portal::admin_email: { get_input: gromacs_portal_admin_email }
          gromacs::portal::gromacs_cpu_nr: { get_input: gromacs_portal_gromacs_cpu_nr }
          gromacs::portal::user_storetime: { get_input: gromacs_portal_user_storetime }
          gromacs::portal::user_maxjob: { get_input: gromacs_portal_user_maxjob }
          gromacs::portal::user_simtime: { get_input: gromacs_portal_user_simtime }
          gromacs::portal::auth_enabled: { get_input: gromacs_portal_auth_enabled }
          gromacs::portal::auth_service_key_b64: { get_input: gromacs_portal_auth_service_key_b64 }
          gromacs::portal::auth_service_cert_b64: { get_input: gromacs_portal_auth_service_cert_b64 }
          gromacs::portal::auth_service_meta_b64: { get_input: gromacs_portal_auth_service_meta_b64 }
          gromacs::portal::dyndns_enabled: { get_input: gromacs_portal_dyndns_enabled }
          gromacs::portal::dyndns_hostname: { get_input: gromacs_portal_dyndns_hostname }
          gromacs::portal::dyndns_server: { get_input: gromacs_portal_dyndns_server }
          gromacs::portal::dyndns_login: { get_input: gromacs_portal_dyndns_login }
          gromacs::portal::dyndns_password: { get_input: gromacs_portal_dyndns_password }
          gromacs::portal::dyndns_ssl: { get_input: gromacs_portal_dyndns_ssl }
          gromacs::user::public_key: { get_input: gromacs_user_public_key }
          gromacs::user::private_key_b64: { get_input: gromacs_user_private_key_b64 }
          westlife::postfix::root_recipient: { get_input: gromacs_portal_admin_email }
          westlife::postfix::gromacs_recipient: { get_input: gromacs_portal_admin_email }
          westlife::volume::device: /dev/vdc
          westlife::volume::fstype: ext4
          westlife::volume::mountpoint: /data
          westlife::volume::mode: "1777"
    relationships:
      - type: cloudify.relationships.contained_in
        target: olinNode
      - type: gromacs.relationships.puppet.connected_to
        target: torqueServer
      - type: cloudify.relationships.depends_on
        target: olinStorage

  torqueServer:
    type: _NODE_TORQUESERVER_
    instances:
      deploy: 1
    properties:
      fabric_env: *fabric_env
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/torque_server.pp
    relationships:
      - type: cloudify.relationships.contained_in
        target: olinNode
      - type: cloudify.relationships.depends_on
        target: olinStorage

  # worker node running on cloud (OCCI)
  workerNode:
    type: _NODE_SERVER_
    properties:
      name: "Gromacs worker node"
      resource_config:
        os_tpl: { get_input: worker_occi_os_tpl }
        resource_tpl: { get_input: worker_occi_resource_tpl }
        availability_zone: { get_input: worker_occi_availability_zone }
        network: { get_input: worker_occi_network }
        network_pool: { get_input: worker_occi_network_pool }
      agent_config: *agent_configuration
      cloud_config: *cloud_configuration
      occi_config: *occi_configuration
      fabric_env: *fabric_env

  workerScratch:
    type: cloudify.occi.nodes.Volume
    properties:
      size: { get_input: worker_occi_scratch_size }
      availability_zone: { get_input: worker_occi_availability_zone }
      occi_config: *occi_configuration
    interfaces:
      cloudify.interfaces.lifecycle:
        delete:
          inputs:
            wait_finish: false
    relationships:
      - type: cloudify.occi.relationships.volume_contained_in_server
        target: workerNode
        target_interfaces:
          cloudify.interfaces.relationship_lifecycle:
            unlink:
              inputs:
                skip_action: true

  torqueMom:
    type: _NODE_SWCOMPONENT_
    instances:
      deploy: 1
    properties:
      fabric_env: *fabric_env
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/torque_mom.pp
        hiera:
          westlife::volume::device: /dev/vdc
          westlife::volume::fstype: ext4
          westlife::volume::mountpoint: /scratch
          westlife::volume::mode: "1777"
    relationships:
      - type: cloudify.relationships.contained_in
        target: workerNode
      - type: cloudify.relationships.depends_on
        target: workerScratch
      - type: cloudify.relationships.depends_on
        target: gromacs
      - type: gromacs.relationships.puppet.connected_to
        target: torqueServer
        source_interfaces:
          cloudify.interfaces.relationship_lifecycle:
            postconfigure:
              inputs:
                manifest: manifests/torque_mom.pp     # nastaveni jmena/np mom na serveru
            unlink:
              inputs:
                manifest: manifests/torque_mom.pp     # zruseni np mom na serveru
        target_interfaces:
          cloudify.interfaces.relationship_lifecycle:
            preconfigure:
              inputs:
                manifest: manifests/torque_server.pp  # nastaveni ::torque_sever_name
            establish:
              inputs:
                manifest: manifests/torque_server.pp  # rekonfigurace serveru
            unlink:
              inputs:
                manifest: manifests/torque_server.pp  # rekonfigurace serveru

  gromacs:
    type: _NODE_SWCOMPONENT_
    instances:
      deploy: 1
    properties:
      fabric_env: *fabric_env
      puppet_config:
        <<: *puppet_config
        manifests:
          start: manifests/gromacs.pp
        hiera:
          cuda::release: { get_input: cuda_release }
          gromacs::user::public_key: { get_input: gromacs_user_public_key }
          gromacs::user::private_key_b64: { get_input: gromacs_user_private_key_b64 }
    relationships:
      - type: cloudify.relationships.contained_in
        target: workerNode
      - type: cloudify.relationships.depends_on
        target: workerScratch
',`errprint(Missing definition of _PROVISIONER_ in the inputs
)m4exit(1)')

groups:
  workerNodes:
    members: [_NAME_WORKERNODE_]

  healWorkerNodes:
    members: [_NAME_WORKERNODE_]
    #members: [workerNodes]
    policies:
      simple_autoheal_policy:
        type: cloudify.policies.types.host_failure
        properties:
          service:
            - .*_NAME_WORKERNODE_.*.cpu.total.system
          interval_between_workflows: 1800
        triggers:
          auto_heal_trigger:
            type: cloudify.policies.triggers.execute_workflow
            parameters:
              workflow: heal
              workflow_parameters:
                node_instance_id: { 'get_property': [ SELF, node_id ] }
                diagnose_value: { 'get_property': [ SELF, diagnose ] }

  scaleWorkerNodes:
    members: [_NAME_TORQUESERVER_]
    policies:
      out:
        type: cloudify.policies.types.threshold
        properties:
          stability_time: 600
          upper_bound: true
          threshold: 2
          service: '.*torque.jobs.queued$'
          interval_between_workflows: 1800
        triggers:
          execute_scale_workflow:
            type: cloudify.policies.triggers.execute_workflow
            parameters:
              workflow: scale_min_max
              workflow_parameters:
                delta: 1
                scalable_entity_name: workerNodes
                scale_compute: true
                max_instances: _WORKERS_MAX_
      in:
        type: cloudify.policies.types.threshold
        properties:
          stability_time: 600
          upper_bound: false
          threshold: 0
          service: '.*torque.nodes.busy$'
          interval_between_workflows: 1800
        triggers:
          execute_scale_workflow:
            type: cloudify.policies.triggers.execute_workflow
            parameters:
              workflow: scale_min_max
              workflow_parameters:
                delta: -1
                scalable_entity_name: workerNodes
                scale_compute: true
                min_instances: _WORKERS_MIN_

policies:
  scaleWorkerNodes:
    type: cloudify.policies.scaling
    targets: [workerNodes]
    properties:
      default_instances: _WORKERS_
      min_instances: _WORKERS_MIN_
      max_instances: _WORKERS_MAX_

outputs:
  web_endpoint:
    description: Gromacs portal endpoint
    value: { concat: ['http://', { get_attribute: [_NAME_OLINNODE_, ip] }] }

# vim: set syntax=yaml
