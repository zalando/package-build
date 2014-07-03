#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement
import os
import glob
from shutil import copy
from string import Template
import json

from fabric.api import local, run, sudo, execute, put
from fabric.context_managers import settings, cd, lcd, hide
from fabric.decorators import task, hosts, with_settings
from fabric.utils import abort
from fabric.state import env
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

PACKAGE_FORMAT = {'centos6.5': 'rpm', 'ubuntu12.04': 'deb', 'ubuntu14.04': 'deb'}


# some repo_* commands must run as root, because sudo won't allow access to the GPG keyring

@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_rpm_init():
    package_ensure('createrepo')
    dir_ensure('{0}/archive/'.format(env.repo_rpm_root), recursive=True)

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
    put(package, '{0}/archive/'.format(env.repo_deb_root))
    package = package.split('/')[-1]
    run('reprepro -b {0} includedeb {1} {0}/archive/{2}'.format(env.repo_deb_root, dist, package))


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_del(package, dist='precise'):
    run('reprepro -b {0} remove {1} {2}'.format(env.repo_deb_root, dist, package))


@task
def package_info(package):
    info = {
        'version': None,
        'description': None,
        'arch': None,
        'dependencies': [],
        'release': None,
    }
    with hide('output', 'running'):
        os.path.isfile(package) or abort('{0} doesn\'t exist.'.format(package))

        if package.endswith('.deb'):
            info['version'] = local('dpkg --field {0} Version'.format(package), capture=True)

            info['description'] = local('dpkg --field {0} Description'.format(package), capture=True)

            info['arch'] = local('dpkg --field {0} Architecture'.format(package), capture=True)

            info['release'] = local('dpkg --field {0} Revision'.format(package), capture=True)

            dependencies = local('dpkg --field {0} Depends'.format(package), capture=True)
            for dependency in dependencies.split(','):
                dependency = dependency.replace('(', '').replace(')', '').replace(' ', '')
                if not ('>=' in dependency or '<=' in dependency) and dependency.count('=') == 1:
                    dependency = dependency.replace('=', '==')
                info['dependencies'].append(dependency)

        if package.endswith('.rpm'):
            info['version'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{VERSION}} {0}'.format(package),
                                    capture=True)

            info['description'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{SUMMARY}} {0}'.format(package),
                                        capture=True)

            info['arch'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{ARCH}} {0}'.format(package), capture=True)

            info['release'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{RELEASE}} {0}'.format(package),
                                    capture=True)

            dependencies = local('rpm -qpR {0}'.format(package), capture=True)
            for dependency in dependencies.split('\n'):
                info['dependencies'].append(dependency.strip())

    print json.dumps(info, indent=2)
    return info


@task
def build_package(url):

    execute(build_pypi, url)
    execute(prepare_builddir, url)

    path = package_name(url)

    package_dependencies = []
    if os.path.isfile('{0}/package.json'.format(path)):
        with open('{0}/package.json'.format(path), 'r') as fh:
            package_dependencies = json.load(fh).items()
    else:
        package_dependencies = [(t, []) for t in PACKAGE_FORMAT.keys()]

    for target, dependencies in package_dependencies:
        package = None
        package_format = PACKAGE_FORMAT.get(target, 'deb')

        pypi_uri = 'http://pypi.python.org/simple'
        if path.startswith('zalando-'):
            pypi_uri = 'http://{0}/simple/'.format(env.repo_host)

        if dependencies:
            dependencies = '--no-auto-depends ' + ' '.join([' -d "{0}"'.format(d) for d in dependencies])

        print 'creating vagrant object with root dir ./{0}'.format(path)
        v = vagrant.Vagrant(root=path)
        print 'running vagrant up for machine {0}'.format(target)
        v.up(vm_name=target)

        with settings(cd('/vagrant'), host_string=v.user_hostname_port(vm_name=target),
                      key_filename=v.keyfile(vm_name=target), disable_known_hosts=True):
            # this is neccesarry because `fpm` looks in a folder equally named like given with the -n option for setup.py to detect the correct version number of the resulting package
            file_link('/vagrant', '/vagrant/{0}'.format(path))
            print 'build {0}.{1} on {2} ({3})'.format(path, package_format, v.user_hostname_port(vm_name=target),
                                                      target)
            messages = sudo('fpm -s python --python-pypi {0} -t {2} {3} --force --name {1} "{1}"'.format(pypi_uri,
                            path, package_format, dependencies))

            for message in messages.split('\n'):
                if 'Created package' in message:
                    package = message.split(':path=>')[1].replace('"', '').replace('}', '')
                    print 'created package "{0}"'.format(package)

        # @TODO detect the correct distribution for uploading into the repos
        if package:
            v.halt(vm_name=target)
            if package_format == 'rpm':
                execute(repo_rpm_add, '{0}/{1}'.format(path, package))
            elif package_format == 'deb':
                execute(repo_deb_add, '{0}/{1}'.format(path, package))
            else:
                print 'no method to add package "{0}" to a repository'.format(package)
        else:
            print 'no package has been created, you may want to inspect the state in the machine:'
            print 'cd {0}/ && vagrant ssh {1}'.format(path, target)


@task
def prepare_builddir(url):
    path = package_name(url)
    execute(git_checkout, url)

    copy('Vagrantfile', path)
    copy('boxes', path)
    for file in glob.glob('provision*sh'):
        copy(file, path)


@task
def build_pypi(url):
    path = package_name(url)
    sha = execute(git_checkout, url)
    sha = sha['<local-only>']

    with lcd(path):
        output = local('python setup.py sdist', capture=True)
        package_name_tgz = None
        for line in output.split('\n'):
            if line.startswith('creating'):
                package_name_tgz = line.split(' ')[1].strip()
                break

        if not package_name_tgz:
            abort('unable to parse name of package\'s tar.gz file')

        with settings(host_string=env.repo_host):
            put('dist/{0}.tar.gz'.format(package_name_tgz), '{0}/{1}'.format(env.repo_pypi_root, path), use_sudo=True)
        local('ln -sf dist/{1}.tar.gz {0}.tar.gz'.format(sha, package_name_tgz))
        return sha


def package_name(url):
    ''' get the package name from a git repo url '''

    return url.split('/')[-1].replace('.git', '')


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

    repo.remote().pull(refspec='master')
    commit = repo.commit()
    print 'updated to SHA {0}'.format(commit.hexsha)
    return commit.hexsha

