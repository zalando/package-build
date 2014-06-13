#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement
import os
import glob
from shutil import copy
from string import Template

from fabric.api import local, run, sudo, execute, put
from fabric.context_managers import settings, cd, lcd, hide
from fabric.decorators import task, hosts, with_settings
from fabric.utils import abort
from fabric.state import env
from fabric.contrib.files import upload_template
from cuisine import package_ensure, dir_ensure, file_link
from git import Repo
from git.remote import Remote
import vagrant

env.repo_host = 'iftp.zalando.net'
env.repo_deb_root = '/data/zalando/iftp.zalando.net/htdocs/repo/apt/'
env.repo_rpm_root = '/data/zalando/iftp.zalando.net/htdocs/repo/centos/'
env.repo_pypi_root = '/data/zalando/iftp.zalando.net/htdocs/simple/'

RPM_RELEASES = ['6']
RPM_COMPONENTS = ['base', 'updates', 'extras']
RPM_ARCHS = ['i386', 'x86_64']

DEB_RELEASES = ['precise', 'trusty']


### repo commands

# some repo_* commands must run as root, because sudo won't allow access to the GPG keyring

@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_rpm_init():
    package_ensure('createrepo')
    ensure_dir('{0}/archive/'.format(env.repo_rpm_root))

    for release in RPM_RELEASES:
        for component in RPM_COMPONENTS:
            for arch in RPM_ARCHS:
                path = '/'.join[env.repo_rpm_root, release, component, arch]
                dir_ensure(path, recursive=True)
                run('createrepo {0}'.format(path))


@hosts(env.repo_host)
@task
def repo_rpm_list(dist='6'):
    with hide('output'):
        output = run('cd {0} && find {1} -type f -name "*rpm"'.format(env.repo_rpm_root, dist))
        for line in output.split('\n'):
            dist, component, arch, package = line.split('/')
            print '{0}: {1}'.format('|'.join([dist, component, arch]), package)


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_rpm_add(package, dist='6', component='base'):

    arch = 'x86_64'
    if any(map(lambda arch: arch in package, ['i386, i586, i686'])):
        arch = 'i386'

    put(package, '{0}/archive/'.format(env.repo_rpm_root))
    package = package.split('/')[-1]
    path = '/'.join([env.repo_rpm_root, dist, component, arch])
    run('cp {0}/archive/{1} {2}'.format(env.repo_rpm_root, package, path))
    run('createrepo {0}'.format(path))


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_rpm_del(package, dist='6', component='base'):
    path = '/'.join([env.repo_rpm_root, dist, component])
    run('find {0} -name "*{1}*" -exec mv {{}} {2}/archive/ \;'.format(path, package, env.repo_rpm_root))
    run('createrepo {0}'.format(path))


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_init():
    package_ensure('reprepro')
    dir_ensure('{0}/archive/'.format(env.repo_deb_root), recursive=True)
    dir_ensure('{0}/conf/'.format(env.repo_deb_root), recursive=True)

    filename = 'distributions'
    with open('{0}.tmpl'.format(filename), 'r') as tf:
        template = Template(tf.read())

    with open(filename, 'w') as fh:
        for release in DEB_RELEASES:
            fh.write(template.safe_substitute(codename=release, codename_uppercase=release.title()))

    put(filename, '{0}/conf/{1}'.format(env.repo_deb_root, filename))


@hosts(env.repo_host)
@task
def repo_deb_list(dist='precise'):
    sudo('reprepro -b {0} list {1}'.format(env.repo_deb_root, dist))


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_add(package, dist='precise'):
    put(package, '{0}/import/'.format(env.repo_deb_root))
    package = package.split('/')[-1]
    run('reprepro -b {0} includedeb {1} {0}/import/{2}'.format(env.repo_deb_root, dist, package))


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_del(package, dist='precise'):
    run('reprepro -b {0} remove {1} {2}'.format(env.repo_deb_root, dist, package))


### helper commands

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
def build_package_deb(package_name):

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
        package_dependencies = execute(deps_list_debian, package)
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
            execute(build_package, package_dependency)


@task
def build_package(url):

    execute(build_pypi, url)
    execute(prepare_builddir, url)

    # @TODO: iterate over all the targets in a target's project.json
    # @TODO: get dependencies from project's project.json
    for machine_name, package_format in {'centos6.5': 'rpm', 'ubuntu12.04': 'deb'}.items():
        path = package_name(url)
        package = None
        pypi_uri = 'http://{0}/simple/'.format(env.repo_host)

        print 'creating vagrant object with root dir ./%s' % path
        v = vagrant.Vagrant(root=path)
        print 'running vagrant up for machine %s' % machine_name
        v.up(vm_name=machine_name)

        with settings(cd('/vagrant'), host_string=v.user_hostname_port(vm_name=machine_name),
                      key_filename=v.keyfile(vm_name=machine_name), disable_known_hosts=True):
            # this is neccesarry because `fpm` looks in a folder equally named like given with the -n option for setup.py to detect the correct version number of the resulting package
            file_link('/vagrant', '/vagrant/{0}'.format(path))
            print 'build {0}.{1} on {2} ({3})'.format(path, package_format, v.user_hostname_port(vm_name=machine_name), machine_name)
            messages = sudo('fpm -s python --python-pypi {0} -t {2} --force --name {1} "{1}"'.format(pypi_uri, path,
                            package_format))

            for message in messages.split('\n'):
                if 'Created package' in message:
                    package = message.split(':path=>')[1].replace('"', '').replace('}', '')
                    print 'created package "{0}"'.format(package)

        # @TODO detect the correct distribution for uploading into the repos
        if package:
            v.halt(vm_name=machine_name)
            if package_format == 'rpm':
                execute(repo_rpm_add, '{0}/{1}'.format(path, package))
            elif package_format == 'deb':
                execute(repo_deb_add, '{0}/{1}'.format(path, package))
            else:
                print 'no method to add package "{0}" to a repository'.format(package)
        else:
            print 'no package has been created, you may want to inspect the state in the machine:'
            print 'cd {0}/ && vagrant ssh {1}'.format(path, machine_name)


@task
def prepare_builddir(url):
    path = package_name(url)
    execute(git_checkout, url)

    copy('Vagrantfile', path)
    copy('boxes', path)
    for file in glob.glob('provision*sh'):
        copy(file, path)


@hosts(env.repo_host)
@with_settings(user='root')
@task
def build_pypi(url):
    path = package_name(url)
    execute(git_checkout, url)

    with lcd(path):
        local('python setup.py -q sdist')
        put('dist/*.tar.gz', '{0}/{1}'.format(env.repo_pypi_root, path))


def package_name(url):
    ''' get the package name from a git repo url '''

    return url.split('/')[-1].replace('.git', '')


### git commands

@task
def git_checkout(url):
    path = package_name(url)

    if not os.path.isdir(path):
        repo = Repo.clone_from(url, path)
    else:
        repo = Repo(path)
        # ensure that the remote "origin" is set to the correct url
        if 'origin' in [remote.name for remote in repo.remotes]:
            Remote.remove(repo, 'origin')
        Remote.add(repo, 'origin', url)

    repo.remote().pull()

