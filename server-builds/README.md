# Summary

Each directory maps to a server build which contains the packer and vagrantfile used for the build.


# Installtion


Vagrant install guide: https://www.vagrantup.com/docs/installation/

# Usage
## Vagrant
Based on: https://github.com/mitchellh/vagrant-aws

Install using standard Vagrant 1.1+ plugin installation methods. After
installing, `vagrant up` and specify the `aws` provider. An example is
shown below.

```
$ vagrant plugin install vagrant-aws

$ vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
...
```
Only need to do the above once. Need to do the below for each vagrantfile
```
$ vagrant up --provider=aws
...
```
Of course prior to doing this, you'll need to obtain an AWS-compatible
box file for Vagrant.

# Common Commands
Must run each of the below from the same directory where the vagrantfile and state file exists. The commands are then relative/effect that instance.

```
$ vagrant ssh  # Login into instance - https://www.vagrantup.com/docs/cli/ssh.html
$ vagrant halt  # Stop/Shutdown instance - https://www.vagrantup.com/docs/cli/halt.html
$ vagrant up  # Start instance - https://www.vagrantup.com/docs/cli/status.html
$ vagrant status  # Current instance state - https://www.vagrantup.com/docs/cli/status.html
...
```
## Packer
These packer templates are expecting variable values from an external JSON file. You'll need to populate the JSON file and pass it as a parameter when running packer build. Template variable files can be viewed in /variables/ DIR, the build command will look like this:

```
packer build -var-file=variables.json template.json

E.g
packer build -var-file=./variables/devFlex.json
```
