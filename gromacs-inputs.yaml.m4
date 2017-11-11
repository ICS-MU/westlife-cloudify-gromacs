############################################
# OCCI authentication options

# OCCI server URL, defaults to the CESNET's FedCloud site
occi_endpoint: 'https://carach5.ics.muni.cz:11443'

# OCCI authentication method, valid options: x509, token, basic, digest, none
occi_auth: 'x509'

# OCCI username for basic or digest authentication, defaults to "anonymous"
occi_username: ''

# OCCI password for basic, digest and x509 authentication
occi_password: ''

# OCCI path to user's x509 credentials
occi_user_cred: '/tmp/x509up_u1000'

# OCCI path to CA certificates directory
occi_ca_path: ''

# OCCI using VOMS credentials; modifies behavior of the X509 authN module
occi_voms: True


############################################
# Contextualization

# remote user for accessing the portal instances
cc_username: 'cfy'

# SSH public key for remote user
cc_public_key: 'include(`resources/ssh_cfy/id_rsa.pub')' 

# SSH private key (filename or inline) for remote user
# TODO: better dettect CFM path
cc_private_key_filename: 'ifdef(`_CFM_',`/opt/manager/resources/blueprints/_CFM_BLUEPRINT_/resources/ssh_cfy/id_rsa',`resources/ssh_cfy/id_rsa')'


############################################
# Main node (portal, batch server) deployment parameters

# OS template
olin_os_tpl: 'uuid_enmr_centos_7_cerit_sc_187'

# sizing
olin_resource_tpl: 'large'

# availability zone
olin_availability_zone: 'uuid_fedcloud_cerit_sc_103'

# scratch size (in GB)
olin_scratch_size: 30


############################################
# Worker node deployment parameters

# OS template
worker_os_tpl: 'uuid_enmr_centos_7_cerit_sc_187'

# sizing
worker_resource_tpl: 'large'

# availability zone
worker_availability_zone: 'uuid_fedcloud_cerit_sc_103'

# scratch size (in GB)
worker_scratch_size: 30


############################################
# Worker nodes count (autoscaling)
#
# Note: Following parameters are specified as m4 macros, because
# in the blueprint where they are required, inputs can't be used for
# on that place :( Please, respect the different syntax.
#
# In the m4 processed files, these parameters are hidden
#
define(_WORKERS_,       2)dnl	# initial workers count
define(_WORKERS_MIN_,   1)dnl	# minimum workers with autoscaling
define(_WORKERS_MAX_,   3)dnl	# maximum workers with autoscaling


############################################
# Application

# version of CUDA Toolkit deployed on GPU workers
cuda_release: '7.0'

# portal servername for redirects, SSL certificates, defaults to portal FQDN
gromacs_portal_servername: NULL

# enable https:// only access on the web portal secured by Let's Encrypt
gromacs_portal_ssl_enabled: False   # if True, setup valid admin e-mail below

# your valid contact e-mail address
gromacs_portal_admin_email: 'root@localhost'

# user options
gromacs_portal_user_storetime: 30  #days
gromacs_portal_user_maxjob: 5
gromacs_portal_user_simtime: 10.0

# Gromacs options
gromacs_portal_gromacs_cpu_nr: 2  # -1=node exclusive

# DynDNS: connection parameters for frontend registration via dyndns API
gromacs_portal_dyndns_enabled: False
gromacs_portal_dyndns_hostname: ''
gromacs_portal_dyndns_server: ''
gromacs_portal_dyndns_login: ''
gromacs_portal_dyndns_password: ''
gromacs_portal_dyndns_ssl: 'yes'            # 'yes' or 'no'

# user SAML authentication via mod_auth_mellon
gromacs_portal_auth_enabled: False   # if True, SSL needs to be enabled
gromacs_portal_auth_service_key_b64:  'esyscmd(base64 -w0 service.key)'
gromacs_portal_auth_service_cert_b64: 'esyscmd(base64 -w0 service.cert)'
gromacs_portal_auth_service_meta_b64: 'esyscmd(base64 -w0 service.xml)'

# SSH public key of the unprivileged gromacs user used for the computation
gromacs_user_public_key: 'include(`resources/ssh_gromacs/id_rsa.pub')'

# SSH private key of the gromacs user
gromacs_user_private_key_b64: 'esyscmd(base64 -w0 resources/ssh_gromacs/id_rsa)'

# vim: set syntax=yaml
