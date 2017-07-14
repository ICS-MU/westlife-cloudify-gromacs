INPUTS=gromacs-inputs.yaml
M4INPUTS=$(INPUTS).m4
BLUEPRINT=gromacs-blueprint.yaml
M4BLUEPRINT=$(BLUEPRINT).m4
CFM_BLUEPRINT=gromacs
CFM_DEPLOYMENT=gromacs
RETRIES=50
VIRTUAL_ENV?=~/cfy
GROMACS_PORTAL?=git@github.com:ICS-MU/westlife-gromacs-portal.git
CFY_VERSION?=3.4.2

.PHONY: blueprints inputs validate test clean bootstrap bootstrap-cfy bootstrap-occi

# blueprints
blueprints: cfy-$(BLUEPRINT) cfm-$(BLUEPRINT)

cfy-$(BLUEPRINT): $(M4BLUEPRINT) cfy-$(INPUTS)
	m4 $(M4BLUEPRINT) >".$@"
	mv ".$@" $@

cfm-$(BLUEPRINT): $(M4BLUEPRINT) cfy-$(INPUTS)
	m4 -D_CFM_ $(M4BLUEPRINT) >".$@"
	mv ".$@" $@

# inputs
inputs: cfy-$(INPUTS) cfm-$(INPUTS)

cfy-$(INPUTS): $(M4INPUTS) resources/ssh_cfy/id_rsa resources/ssh_gromacs/id_rsa
	m4 $(M4INPUTS) >".$@"
	mv ".$@" $@

cfm-$(INPUTS): $(M4INPUTS) resources/ssh_cfy/id_rsa resources/ssh_gromacs/id_rsa
	m4 -D_CFM_ -D_CFM_BLUEPRINT_=$(CFM_BLUEPRINT) $(M4INPUTS) >".$@"
	mv ".$@" $@

validate: cfy-$(BLUEPRINT) cfm-$(BLUEPRINT)
	cfy blueprints validate -p cfy-$(BLUEPRINT)
	cfy blueprints validate -p cfm-$(BLUEPRINT)

test: validate inputs cfy-init clean

clean:
	-rm -rf cfy-$(INPUTS) .cfy-$(INPUTS) cfm-$(INPUTS) .cfm-$(INPUTS) cfy-$(BLUEPRINT) .cfy-$(BLUEPRINT) cfm-$(BLUEPRINT) .cfm-$(BLUEPRINT) resources/puppet.tar.gz resources/ssh_cfy/ resources/ssh_gromacs/ local-storage/ resources/puppet/site/gromacs/files/private/gromacs-portal.tar.gz

cfy-deploy: cfy-init cfy-exec-install

cfy-undeploy: cfy-exec-uninstall

cfy-test: cfy-deploy cfy-undeploy

cfm-deploy: cfm-init cfm-exec-install

cfm-undeploy:
	-cfy executions start -d $(CFM_DEPLOYMENT) -w uninstall
	-cfy deployments delete -d $(CFM_DEPLOYMENT)
	cfy blueprints delete -b $(CFM_BLUEPRINT)

cfm-test: cfm-deploy cfm-exec-uninstall cfm-clean


### Resources ####################################

resources/ssh_cfy/id_rsa:
	mkdir -p resources/ssh_cfy/
	ssh-keygen -N '' -f resources/ssh_cfy/id_rsa

resources/ssh_gromacs/id_rsa:
	mkdir -p resources/ssh_gromacs/
	ssh-keygen -N '' -f resources/ssh_gromacs/id_rsa

#TODO: Puppet vcsrepo
resources/gromacs-portal:
	git clone $(GROMACS_PORTAL) $@

resources/puppet/site/gromacs/files/private/gromacs-portal.tar.gz: resources/gromacs-portal
	mkdir -p resources/puppet/site/gromacs/files/private/
	tar -czvf $@ -C $? .

resources/puppet.tar.gz: resources/puppet/site/gromacs/files/private/gromacs-portal.tar.gz
	tar -czvf $@ -C resources/puppet/ .


### Standalone deployment ########################

cfy-init: cfy-$(BLUEPRINT) cfy-$(INPUTS) resources/puppet.tar.gz
	cfy local init -p cfy-$(BLUEPRINT) -i cfy-$(INPUTS) --install-plugins

# execute deployment
cfy-exec-%:
	cfy local execute -w $* --task-retries $(RETRIES)


### Cloudify Manager managed deployment ##########

cfm-init: cfm-$(BLUEPRINT) cfm-$(INPUTS) resources/puppet.tar.gz
	cfy blueprints upload -b $(CFM_BLUEPRINT) -p cfm-$(BLUEPRINT)
	cfy deployments create -b $(CFM_BLUEPRINT) -d $(CFM_DEPLOYMENT) -i cfm-$(INPUTS)

cfm-exec-%:
	cfy executions start -d $(CFM_DEPLOYMENT) -w $*
	sleep 10

cfm-scale-up:
	cfy executions start -d $(CFM_DEPLOYMENT) -w scale -p 'scalable_entity_name=workerNodes' -p 'delta=+1'

cfm-scale-down:
	cfy executions start -d $(CFM_DEPLOYMENT) -w scale -p 'scalable_entity_name=workerNodes' -p 'delta=-1'


### Bootstrap ####################################

bootstrap: bootstrap-cfy bootstrap-occi

bootstrap-cfy:
	yum install -y python-virtualenv python-pip || \
		apt-get install -y python-virtualenv python-pip
	wget -O get-cloudify.py 'http://repository.cloudifysource.org/org/cloudify3/get-cloudify.py'
ifeq ($(CFY_VERSION), )
	python get-cloudify.py -e $(VIRTUAL_ENV) --upgrade
else
	python get-cloudify.py -e $(VIRTUAL_ENV) --upgrade --version $(CFY_VERSION)
endif
	unlink get-cloudify.py

bootstrap-occi:
	yum install -y ruby-devel openssl-devel gcc gcc-c++ ruby rubygems || \
		apt-get install -y ruby rubygems ruby-dev
	gem install occi-cli
