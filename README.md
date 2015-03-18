Package Building
================
*created Wednesday, 11. June 2014 - updated Wednesday, 18. March 2015*

## Setup
You have to install this requirements:

- [VirtualBox](https://www.virtualbox.org/)
- [Vagrant](http://www.vagrantup.com/)

    sudo apt-get install virtualbox virtualbox-guest-additions-iso

    wget https://dl.bintray.com/mitchellh/vagrant/vagrant_1.4.3_x86_64.deb
    sudo dpkg -i vagrant_1.4.3_x86_64.deb

    git clone ssh://git@stash.zalando.net:7999/system/package-build.git

## Re-building packages with fpm-cookery

This way of package building is based on [fpm](https://github.com/jordansissel/fpm) and [fpm-cookery](https://github.com/bernd/fpm-cookery).
It has been created in order to make Debian packaging for Ubuntu much easier. It's using fpm-cookery recipes to make repeatable build processes (package version updates) less painful.

fpm-cookery automatically builds only a package for the distribution/OS where it's running on [source](https://github.com/bernd/fpm-cookery/blob/master/spec/facts_spec.rb#L72), so start the desired OS:

    vagrant up {ubuntu12.04,ubuntu14.04,centos6.5}

### More recipe examples

- [https://github.com/bernd/fpm-recipes](https://github.com/bernd/fpm-recipes)
- [https://github.com/piavlo/fpm-recipes-piavlo/tree/master/gearmand](https://github.com/piavlo/fpm-recipes-piavlo/tree/master/gearmand)
- [https://github.com/gocardless/fpm-recipes](https://github.com/gocardless/fpm-recipes)
- [https://github.com/henchmanio/fpm-recipes](https://github.com/henchmanio/fpm-recipes)

## Build native packages from python modules

Build native packages (.deb, .rpm) from pypi modules automatically for different target systems (Ubuntu 12.04, Ubuntu 14.04, Centos 6.5) and push them to internal package repositotries to make them avaialable.

### Concept

- whole process is triggered from Fabric tasks running on the "build host"
- build slaves are vagrant boxes to have always a clean, well defined environment
- Fabric tasks can be run manually from command line or will be triggered from a web server
- this web server polls the SCM system (Git) for changes or can be notified by a HTTP request
- packages to be build should provide a config file, package.json which defines build dependencies for environments ({"ubuntu14.04": ["python-parmiko", "PyYAML", "", ...]})
- packages are build with [fpm](https://github.com/jordansissel/fpm)
- setup.py must have more loose requirements for other python modules than defined in package.json (e.g. if package.json requires PyYAML==3.10, setup.py must have at least also PyYAML==3.10 or PyYAML>=3.10 as dependency). Otherwise the code will fail because it did not find the modules which where in the respective egg-infos.

### Build Environment
Needed in the shared folder of a vagrant node:

- **project repo** checked out from Git for getting the package.json (@TODO: could be retrieved via HTTP from Stash `?raw`)
- **Vagrantfile**
- **provision(-$boxname).sh**
- **cook-recipe.sh**

## Considered Solutions for the Job Scheduling Framework

- [PyCI](http://tbraun89.github.io/pyCI/): minimal CI server
- [Go](http://www.go.cd/)
- [buildbot](http://buildbot.net/): build framework with master/slave architecture, a lot to much
- [dovetail](http://www.aviser.asia/dovetail/): defines build tasks, like `make`, no scheduler
- [elita](https://elita.io/): HTTP API-focused continuous deployment framework
- [taskpy](https://github.com/jakecoffman/taskpy): draft Jenkins rewrite in Python
- [ghetto-CI](http://miohtama.github.io/vvv/tools/ghetto.html): quick & dirty CI in only 145 statements


## Todo

- try other vagrant providers, which might be more performant than virtualbox
- create base images for build hosts, which are already provisioned with `fpm` and other requirements
- maybe add mode to generate "uber"-packages with all requirements built-in

## Publish a package in our repos

[Sysdocu](https://sysdocu.zalando.net/Packages-and-Repos/Internal-Repo#Manage-internal-APT-/-RPM-repositories)

