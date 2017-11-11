tosca_definitions_version: cloudify_dsl_1_3

description: >
  Gromacs portal setup via FedCloud OCCI and Puppet.

define(_NODE_SERVER_,       ifdef(`_CFM_',`gromacs.nodes.MonitoredServer',`gromacs.nodes.Server'))dnl
define(_NODE_TORQUESERVER_, ifdef(`_CFM_',`gromacs.nodes.MonitoredTorqueServer',`gromacs.nodes.TorqueServer'))dnl
define(_NODE_WEBSERVER_,    ifdef(`_CFM_',`gromacs.nodes.MonitoredWebServer', `gromacs.nodes.WebServer'))dnl
define(_NODE_SWCOMPONENT_,  ifdef(`_CFM_',`gromacs.nodes.MonitoredSoftwareComponent', `gromacs.nodes.SoftwareComponent'))dnl

dnl *** From gromacs-inputs.yaml.m4 take only macros, drop regular texts.
divert(`-1')dnl
include(gromacs-inputs.yaml.m4)dnl
divert(`0')dnl

imports:
  - http://getcloudify.org/spec/cloudify/3.4/types.yaml
#  - http://getcloudify.org/spec/fabric-plugin/1.3.1/plugin.yaml
  - https://raw.githubusercontent.com/ICS-MU/westlife-cloudify-fabric-plugin/1.4.2.1/plugin.yaml
  - http://getcloudify.org/spec/diamond-plugin/1.3.1/plugin.yaml
  - https://raw.githubusercontent.com/ICS-MU/westlife-cloudify-occi-plugin/master/plugin.yaml
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

  # contextualization
  cc_username:
    default: cfy
    type: string
  cc_public_key:
    type: string
  cc_private_key_filename:
    type: string
  cc_data:
    default: {}

  # VM parameters
  olin_os_tpl:
    type: string
  olin_resource_tpl:
    type: string
  olin_availability_zone:
    type: string
  olin_scratch_size:
    type: integer
  worker_os_tpl:
    type: string
  worker_resource_tpl:
    type: string
  worker_availability_zone:
    type: string
  worker_scratch_size:
    type: integer

  # Application parameters
  cuda_release:
    type: string
  gromacs_portal_servername:
    type: string
  gromacs_portal_ssl_enabled:
    type: boolean
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
    key_filename: { get_input: cc_private_key_filename }

  agent_configuration: &agent_configuration
    install_method: remote
    user: { get_input: cc_username }
    key: { get_input: cc_private_key_filename }

  puppet_config: &puppet_config
    repo: 'https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm'
    package: 'puppet-agent'
    download: resources/puppet.tar.gz

node_templates:
  olinNode:
    type: _NODE_SERVER_
    properties:
      name: 'Gromacs all-in-one server node'
      resource_config:
        os_tpl: { get_input: olin_os_tpl }
        resource_tpl: { get_input: olin_resource_tpl }
        availability_zone: { get_input: olin_availability_zone }
      agent_config: *agent_configuration
      cloud_config: *cloud_configuration
      occi_config: *occi_configuration
      fabric_env: *fabric_env

  olinStorage:
    type: cloudify.occi.nodes.Volume
    properties:
      size: { get_input: olin_scratch_size }
      availability_zone: { get_input: olin_availability_zone }
      occi_config: *occi_configuration
    relationships:
      - type: cloudify.occi.relationships.volume_contained_in_server
        target: olinNode

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
          westlife::volume::mode: '1777'
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

  workerNode:
    type: _NODE_SERVER_
    properties:
      name: 'Gromacs worker node'
      resource_config:
        os_tpl: { get_input: worker_os_tpl }
        resource_tpl: { get_input: worker_resource_tpl }
        availability_zone: { get_input: worker_availability_zone }
      agent_config: *agent_configuration
      cloud_config: *cloud_configuration
      occi_config: *occi_configuration
      fabric_env: *fabric_env

  workerScratch:
    type: cloudify.occi.nodes.Volume
    properties:
      size: { get_input: worker_scratch_size }
      availability_zone: { get_input: olin_availability_zone }
      occi_config: *occi_configuration
    relationships:
      - type: cloudify.occi.relationships.volume_contained_in_server
        target: workerNode

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
          westlife::volume::mode: '1777'
    relationships:
      - type: cloudify.relationships.contained_in
        target: workerNode
      - type: cloudify.relationships.depends_on
        target: workerScratch
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

groups:
  workerNodes:
    members: [workerNode]

  healWorkerNodes:
    members: [workerNode]
    policies:
      simple_autoheal_policy:
        type: cloudify.policies.types.host_failure
        properties:
          service:
            - .*workerNode.*.cpu.total.system
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
    members: [torqueServer]
    policies:
      up:
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
      down:
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
#      min_instances: _WORKERS_MIN_
#      max_instances: _WORKERS_MAX_

outputs:
  web_endpoint:
    description: Gromacs portal endpoint
    value:
      url: { concat: ['http://', { get_attribute: [olinNode, ip] }] }

# vim: set syntax=yaml
