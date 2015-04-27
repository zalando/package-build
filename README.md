Package Building
================
*created Wednesday, 11. June 2014 - updated Monday, 27. April 2015*

This is a toolset for creating native system packages, read more on [System Docu](https://sysdocu.zalando.net/Packages-and-Repos).

## Setup

Clone the repo and install Python requirements:

    git clone ssh://git@stash.zalando.net:7999/system/package-build.git
    cd package-build
    sudo pip install -r requirements.txt

## Concept

- whole process is triggered from Fabric tasks running on the "build host"
- build slaves are docker containers to have always a clean, well defined environment
- packages are build with [fpm](https://github.com/jordansissel/fpm) and [fpm-cookery](https://github.com/bernd/fpm-cookery)

## How To

The build environments are provided by docker containers, thus you have to create a new subfolder under `docker/` with a Dockerfile for all the distributions, you want to create a package for. Set the environment variable `RELEASE`, it's used to put the resulting package into an appropriate subfolder to avoid name clashes. It could be also used to determine to which repository the package should be uploaded to later.

The actual package build is done by [fpm](https://github.com/jordansissel/fpm) and [fpm-cookery](https://github.com/bernd/fpm-cookery). So create a `recipe.rb` under an subfolder in `recipes/` and optionally a script called `prepare.sh`, which is meant to be run before `fpm-cook package` is executed.

fpm-cookery automatically builds only a package for the distribution/OS where it's running on [source](https://github.com/bernd/fpm-cookery/blob/master/spec/facts_spec.rb#L72).

### Command Line Examples
To start the packaging process different distributions and packages, see the examples below

Build `facter` for Ubuntu 14.04:

    fab package_build:ubuntu14.04,facter

Build all recipes for Debian 7 ("Wheezy"):

    fab package_build:debian7

### More Recipe Examples

- [https://github.com/bernd/fpm-recipes](https://github.com/bernd/fpm-recipes)
- [https://github.com/piavlo/fpm-recipes-piavlo/tree/master/gearmand](https://github.com/piavlo/fpm-recipes-piavlo/tree/master/gearmand)
- [https://github.com/henchmanio/fpm-recipes](https://github.com/henchmanio/fpm-recipes)
- [https://github.com/Graylog2/fpm-recipes.git](https://github.com/Graylog2/fpm-recipes.git)
- [https://github.com/haf/fpm-recipes.git](https://github.com/haf/fpm-recipes.git)

## Considered Solutions for the Job Scheduling Framework

- [PyCI](http://tbraun89.github.io/pyCI/): minimal CI server
- [Go](http://www.go.cd/) seems to be at very early development stage
- [buildbot](http://buildbot.net/): build framework with master/slave architecture, a lot to much
- [dovetail](http://www.aviser.asia/dovetail/): defines build tasks, like `make`, no scheduler
- [elita](https://elita.io/): HTTP API-focused continuous deployment framework
- [taskpy](https://github.com/jakecoffman/taskpy): draft Jenkins rewrite in Python
- [ghetto-CI](http://miohtama.github.io/vvv/tools/ghetto.html): quick & dirty CI in only 145 statements

## Publish a package in our repos

[Sysdocu](https://sysdocu.zalando.net/Packages-and-Repos/Internal-Repo#Manage-internal-APT-/-RPM-repositories)

