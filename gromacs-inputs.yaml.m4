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

#olin_os_tpl: 'uuid_egi_centos_7_fedcloud_warg_149'
olin_os_tpl: 'uuid_enmr_centos_7_cerit_sc_187'
#olin_resource_tpl: 'small'
olin_resource_tpl: 'extra_large'
olin_availability_zone: 'uuid_fedcloud_cerit_sc_103'
olin_scratch_size: 30

#worker_os_tpl: 'uuid_egi_centos_7_fedcloud_warg_149'
#worker_os_tpl: 'uuid_enmr_centos_7_cerit_sc_187'
worker_os_tpl: 'uuid_enmr_gpgpu_centos_7_cerit_sc_185'
#worker_resource_tpl: 'extra_large'
worker_resource_tpl: 'large'
worker_availability_zone: 'uuid_fedcloud_cerit_sc_103'
worker_scratch_size: 15

dnl
dnl ############################################
dnl # Instances count
dnl #
dnl # Note: these can't be used inside the blueprint as inputs,
dnl # macro definitions for M4 help here to have everything on
dnl # one place. Please, respect the different syntax.
dnl #
define(_WORKERS_,       1)dnl	# initial count
define(_WORKERS_MIN_,   1)dnl	# minimum
define(_WORKERS_MAX_,   3)dnl	# maximum

############################################
# Application

cuda_release: '7.0'
gromacs_portal_enable_ssl: False #if True, setup valid admin e-mail below
gromacs_portal_admin_email: 'root@localhost'
gromacs_user_public_key: 'include(`resources/ssh_gromacs/id_rsa.pub')'
gromacs_user_private_key_b64: 'esyscmd(base64 -w0 resources/ssh_gromacs/id_rsa)'

# vim: set syntax=yaml
