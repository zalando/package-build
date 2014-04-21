#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement
import os

from fabric.api import local, hide, execute
from fabric.decorators import task

@task
def deps_list_debian(package):
    deps = []
    with hide('output', 'running'):
        os.path.isfile(package) or abort('{0} doesn\'t exist.'.format(package))
        deps_string = local('dpkg --field {0} Depends'.format(package), capture=True)
        for dependency in deps_string.split(','):
            dependency = dependency.replace('(', '').replace(')', '').replace(' ','')
            if not ('>=' in dependency or '<=' in dependency) and dependency.count('=')  == 1:
                dependency = dependency.replace('=', '==')
            deps.append(dependency)
    return deps

@task
def pypi_build(package_name):

    package = None

    pypi_uri = 'http://pypi.python.org/simple'
    if package_name.startswith('zalando-'):
        pypi_uri = 'http://iftp.zalando.net/simple'

    messages = local('sudo fpm -s python --python-pypi {0} -t deb --force "{1}"'.format(pypi_uri, package_name), capture=True)
    for message in messages.split('\n'):
        if 'Created deb package' in message:
            package = message.split(':path=>')[1].replace('"','').replace('}','')

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
            package_dependency = package_dependency.replace('python-','')  if  package_dependency.startswith('python-') else package_dependency
            execute('pypi_build', package_dependency)

