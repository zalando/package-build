Package Building
================
*created Wednesday, 11. June 2014 - updated Monday, 09. November 2015*

This is the toolset for creating native system packages (.deb for Debian-like and .rpm for RedHat-like OSes), read more on [System Docu](https://wiki.tm.zalando/Packages-and-Repos).

## Setup

Clone the repo and install Python requirements:

    sudo pip install -r requirements.txt
    cp package-build.yaml-example ~/.config/package-build.yaml
    vim ~/.config/package-build.yaml # adapt to your repo server setup
    fab docker_build # this will setup the required Docker images and could take a while

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

For testing purposes, the created package will not be automatically uploaded and published in our repositories, unless you set the parameter `upload` to `True`:

    fab package_build:debian7,upload=True

Publish a package to the internal repository for ubuntu14.04 ("Trusty"):

    fab repo_deb_add:~/path/to/package.deb

If you want to publish a package in the repos for other distributions, you have to pass them explicitely:

    fab repo_deb_add:~/path/to/package.deb,dist=ubuntu12.04

### More Recipe Examples

- [https://github.com/bernd/fpm-recipes](https://github.com/bernd/fpm-recipes)
- [https://github.com/piavlo/fpm-recipes-piavlo/tree/master/gearmand](https://github.com/piavlo/fpm-recipes-piavlo/tree/master/gearmand)
- [https://github.com/henchmanio/fpm-recipes](https://github.com/henchmanio/fpm-recipes)
- [https://github.com/Graylog2/fpm-recipes.git](https://github.com/Graylog2/fpm-recipes.git)
- [https://github.com/haf/fpm-recipes.git](https://github.com/haf/fpm-recipes.git)

