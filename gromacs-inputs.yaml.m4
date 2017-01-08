############################################
# OCCI authentication options

occi_endpoint: 'https://carach5.ics.muni.cz:11443'
occi_auth: 'x509'
occi_username: ''
occi_password: ''
occi_user_cred: '/tmp/x509up_u1000'
occi_ca_path: ''
occi_voms: True


############################################
# Contextualization

# remote user
cc_username: 'cfy'

# SSH public key
cc_public_key: 'include(`resources/ssh_cfy/id_rsa.pub')'

# SSH private key (filename or inline)
# TODO: better dettect CFM path
cc_private_key_filename: 'ifdef(`_CFM_',`/opt/manager/resources/blueprints/_CFM_BLUEPRINT_/resources/ssh_cfy/id_rsa',`resources/ssh_cfy/id_rsa')'


############################################
# Instances

olin_os_tpl: 'uuid_egi_centos_7_fedcloud_warg_149'
olin_resource_tpl: 'small'
olin_scratch_size: 256
worker_os_tpl: 'uuid_egi_centos_7_fedcloud_warg_149'
worker_resource_tpl: 'medium'
worker_scratch_size: 64


############################################
# Application

cuda_release: '7.0'
gromacs_portal_enable_ssl: True
gromacs_portal_admin_email: 'root@localhost'
gromacs_user_public_key: 'include(`resources/ssh_gromacs/id_rsa.pub')'
gromacs_user_private_key_b64: 'esyscmd(base64 -w0 resources/ssh_gromacs/id_rsa)'

# vim: set syntax=yaml
