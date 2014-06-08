#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement
import os

from fabric.api import local, hide, execute, sudo, put, with_settings, run
from fabric.decorators import task, hosts
from fabric.util import abort
from fabric.state import env

env.build_host = ''
env.repo_host = 'iftp.zalando.net'
env.repo_root = '/data/zalando/iftp.zalando.net/htdocs/repo/apt'

# some repo_* commands must run as root, because sudo won't allow access to the GPG keyring

@hosts(env.repo_host)
@task
def repo_list(dist='precise'):
    sudo('reprepro -b {0} list {1}'.format(env.repo_root, dist))

@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_add(package, dist='precise'):
    put('./{0}'.format(package), '{0}/import/'.format(env.repo_root))
    run('reprepro -b {0} includedeb {1} {0}/import/{2}'.format(env.repo_root, dist, package))

@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_del(package, dist='precise'):
    run('reprepro -b {0} remove {1} {2}'.format(env.repo_root, dist, package))


@task
def deps_list_centos(package):
    # @TODO fpm seems to fail while building a rpm from python packages which has dependencies
    # (see: https://github.com/jordansissel/fpm/issues/571), however - command for listing rpm
    # dependencies: `rpm -qp --requires package.rpm`

    # @TODO CentOS 6.5 also comes with Python2.6 which needs also python-setuptools, and python-argparse
    # as dependencies, PATH and PYTHONPATH have to be adapted too. We can add dependencies while building
    # rpm from deb packages:
    # `fpm -s deb -t rpm -d python-argparse -d python-setuptools python-zalando-cmdb-client_0.9.3_all.deb`
    pass


@task
def deps_list_debian(package):
    deps = []
    with hide('output', 'running'):
        os.path.isfile(package) or abort('{0} doesn\'t exist.'.format(package))
        deps_string = local('dpkg --field {0} Depends'.format(package), capture=True)
        for dependency in deps_string.split(','):
            dependency = dependency.replace('(', '').replace(')', '').replace(' ', '')
            if not ('>=' in dependency or '<=' in dependency) and dependency.count('=') == 1:
                dependency = dependency.replace('=', '==')
            deps.append(dependency)
    return deps


@task
def pypi_build(package_name):

    package = None

    pypi_uri = 'http://pypi.python.org/simple'
    if package_name.startswith('zalando-'):
        pypi_uri = 'http://iftp.zalando.net/simple'

    messages = local('sudo fpm -s python --python-pypi {0} -t deb --force "{1}"'.format(pypi_uri, package_name),
                     capture=True)
    for message in messages.split('\n'):
        if 'Created deb package' in message:
            package = message.split(':path=>')[1].replace('"', '').replace('}', '')

    if package is not None:
        package_dependencies = execute('deps_list_debian', package)
        # execute returns a dict, when Fabric env has no host_list (e.g. runs only locally)
        # therefore, unwrap it
        package_dependencies = package_dependencies['<local-only>']
        if package_dependencies == ['']:
            return
        print package_dependencies
        for package_dependency in package_dependencies:
            # fpm prefixes packages and their dependencies with "python-" by default
            # when they are build from pypi, what makes sense for the destination packages.
            # We have to build the dependencies also from pypi, so remove the prefix here:
            package_dependency = (package_dependency.replace('python-', '') if package_dependency.startswith('python-'
                                  ) else package_dependency)
            execute('pypi_build', package_dependency)

