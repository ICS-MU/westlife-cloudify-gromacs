# Cloudify Gromacs OCCI blueprints

[![Build Status](https://travis-ci.org/vholer/cloudify-gromacs.svg?branch=master)](https://travis-ci.org/vholer/cloudify-gromacs)

## Standalone Cloudify

#### Setup OCCI CLI

```bash
yum install -y ruby-devel openssl-devel gcc gcc-c++ ruby rubygems
gem install occi-cli
```

#### Setup cloudify

```bash
make bootstrap
```

#### Run deployment

First get valid X.509 VOMS certificate into `/tmp/x509up_u1000` and
have `m4` installed.

```bash
source ~/cfy/bin/activate
make cfy-deploy
```

#### Destroy deployment

```bash
make cfy-undeploy
```

## Cloudify Manager

TBD
