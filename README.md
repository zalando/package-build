Package Building
================
*created Wednesday, 11. June 2014 - updated Friday, 13. June 2014*

## Goal

Build native packages (.deb, .rpm) from pypi modules automatically for different target systems (Ubuntu 12.04, Ubuntu 14.04, Centos 6.5) and push them to internal package repositotries to make them avaialable.

## Concept

- whole process is triggered from Fabric tasks running on the "build host"
- build slaves are vagrant boxes to have always a clean, well defined environment
- Fabric tasks can be run manually from command line or will be triggered from a web server
- this web server polls the SCM system (Git) for changes or can be notified HTTP request
- packages to be build should provide a config file, build.json which defines build dependencies for environments ({"ubuntu14.04": ["python-parmiko", "PyYAML", "", ...]})
- packages are build with [fpm](https://github.com/jordansissel/fpm), therefore we build sdist packages first and provide them in a simple pypi repo

## Build Environment
Needed in the shared folder of a vagrant node:

- **project repo** checked out from Git for getting the build.json (@TODO: could be retrieved via HTTP from Stash `?raw`)
- **Vagrantfile**
- **boxes(.json)**
- **provision(-<boxname>).sh**

## Considered Solutions for the Job Scheduling Framework

 - [buildbot](http://buildbot.net/): build framework with master/slave architecture, a lot to much
 - [dovetail](http://www.aviser.asia/dovetail/): defines build tasks, like `make`, no scheduler
 - [elita](https://elita.io/): HTTP API-focused continuous deployment framework
 - [taskpy](https://github.com/jakecoffman/taskpy): draft Jenkins rewrite in Python
 - [ghetto-CI](http://miohtama.github.io/vvv/tools/ghetto.html): quick & dirty CI in only 145 statements

