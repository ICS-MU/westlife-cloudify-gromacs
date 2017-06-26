# Cloudify Gromacs OCCI blueprints

[![Build Status](https://travis-ci.org/ICS-MU/westlife-cloudify-gromacs.svg?branch=master)](https://travis-ci.org/ICS-MU/westlife-cloudify-gromacs)

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

```
make cfy-undeploy
```

## Cloudify Manager

#### Bootstrap CFM

TBD

#### Run deployment

Get valid X.509 VOMS certificate into `/tmp/x509up_u1000` on
the Cloudify Manager instance.

```
source ~/cfy/bin/activate
make cfm-deploy
```

#### Manual scaling

```bash
make cfm-scale-up
make cfm-scale-down
```

#### Destroy deployment

```bash
make cfm-undeploy
```
