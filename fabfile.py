#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement
import os
import glob
from shutil import copy
from string import Template
import json
import time

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

RPM_COMPONENTS = ['base', 'updates', 'extras']
RPM_ARCHS = ['i386', 'x86_64']

PACKAGE_FORMAT = {'centos6.5': 'rpm', 'ubuntu12.04': 'deb', 'ubuntu14.04': 'deb'}


class Package(object):

    name = None
    tgz = None
    rpm = None
    deb = None

    def __init__(self, repo, name=None):
        self.repo = repo
        self.name = name

    @property
    def basename(self):
        ''' get the package name from a git repo url '''

        if self.name:
            return self.name

        return self.repo.split('/')[-1].replace('.git', '')


# some repo_* commands must run as root, because sudo won't allow access to the GPG keyring

@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_rpm_init():
    package_ensure('createrepo')
    dir_ensure('{0}/archive/'.format(env.repo_rpm_root), recursive=True)

    for release, package_format in PACKAGE_FORMAT.items():
        if package_format == 'rpm':
            for component in RPM_COMPONENTS:
                for arch in RPM_ARCHS:
                    path = '/'.join([env.repo_rpm_root, release, component, arch])
                    dir_ensure(path, recursive=True)
                    run('createrepo {0}'.format(path))


@hosts(env.repo_host)
@with_settings(hide('commands'))
@task
def repo_rpm_list(dist='centos6.5'):
    output = run('cd {0} && find {1} -type f -name "*rpm"'.format(env.repo_rpm_root, dist))
    for line in output.split('\n'):
        if line:
            dist, component, arch, package = line.split('/')
            print '{0}: {1}'.format('|'.join([dist, component, arch]), package)


@hosts(env.repo_host)
@with_settings(hide('commands'), user='root')
@task
def repo_rpm_add(package, dist='centos6.5', component='base'):

    arch = 'x86_64'
    if any(map(lambda arch: arch in package, ['i386, i586, i686'])):
        arch = 'i386'

    put(package, '{0}/archive/'.format(env.repo_rpm_root))
    package = package.split('/')[-1]
    path = '/'.join([env.repo_rpm_root, dist, component, arch])
    run('cp {0}/archive/{1} {2}'.format(env.repo_rpm_root, package, path))
    output = run('createrepo {0}'.format(path))
    if output.succeeded:
        print 'added %s to repo' % package


@hosts(env.repo_host)
@with_settings(hide('commands'), user='root')
@task
def repo_rpm_del(packagename, dist='centos6.5', component='base'):
    path = '/'.join([env.repo_rpm_root, dist, component])
    run('find {0} -name "*{1}*" -exec mv {{}} {2}/archive/ \;'.format(path, packagename, env.repo_rpm_root))
    output = run('createrepo {0}'.format(path))
    if output.succeeded:
        print 'deleted %s from repo' % packagename


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
        for release, package_format in PACKAGE_FORMAT.items():
            if package_format == 'deb':
                fh.write(template.safe_substitute(codename=release, codename_uppercase=release.title()))

    put(filename, '{0}/conf/{1}'.format(env.repo_deb_root, filename))


@hosts(env.repo_host)
@with_settings(hide('commands'))
@task
def repo_deb_list(dist='ubuntu12.04'):
    output = sudo('reprepro -b {0} list {1}'.format(env.repo_deb_root, dist))
    for line in output.split('\n'):
        print line


@hosts(env.repo_host)
@with_settings(hide('commands'), user='root')
@task
def repo_deb_add(package, dist='ubuntu12.04'):
    put(package, '{0}/archive/'.format(env.repo_deb_root))
    package = package.split('/')[-1]
    output = run('reprepro -b {0} includedeb {1} {0}/archive/{2}'.format(env.repo_deb_root, dist, package))
    if output.succeeded:
        print 'added %s to repo' % package


@hosts(env.repo_host)
@with_settings(hide('commands'), user='root')
@task
def repo_deb_del(packagename, dist='ubuntu12.04'):
    output = run('reprepro -b {0} remove {1} {2}'.format(env.repo_deb_root, dist, packagename))
    if output.succeeded:
        print 'deleted %s from repo' % packagename


@task
@with_settings(hide('commands'))
def package_info(package):
    info = {
        'version': None,
        'description': None,
        'arch': None,
        'dependencies': [],
        'release': None,
    }
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
        info['version'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{VERSION}} {0}'.format(package), capture=True)

        info['description'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{SUMMARY}} {0}'.format(package),
                                    capture=True)

        info['arch'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{ARCH}} {0}'.format(package), capture=True)

        info['release'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{RELEASE}} {0}'.format(package), capture=True)

        dependencies = local('rpm -qpR {0}'.format(package), capture=True)
        for dependency in dependencies.split('\n'):
            info['dependencies'].append(dependency.strip())

    print json.dumps(info, indent=2)
    return info


@task
def build_package(repo, name=None):
    start_time = time.time()

    p = execute(build_pypi, repo, name)
    p = p['<local-only>']

    # put all files for the build host in place
    copy('Vagrantfile', p.basename)
    copy('boxes', p.basename)
    for file in glob.glob('provision*sh'):
        copy(file, p.basename)

    # detect specific dependencies for targets or fallback to autodetection
    package_dependencies = []
    if os.path.isfile('{0}/package.json'.format(p.basename)):
        with open('{0}/package.json'.format(p.basename), 'r') as fh:
            package_dependencies = json.load(fh).items()
    else:
        package_dependencies = [(t, '') for t in PACKAGE_FORMAT.keys()]

    for target, dependencies in package_dependencies:
        package_format = PACKAGE_FORMAT.get(target, 'deb')

        if dependencies:
            dependencies = '--no-auto-depends ' + ' '.join([' -d "{0}"'.format(d) for d in dependencies])

        print 'creating vagrant object with root dir ./{0}'.format(p.basename)
        v = vagrant.Vagrant(root=p.basename)
        print 'running vagrant up for machine {0}'.format(target)
        v.up(vm_name=target)

        with settings(cd('/vagrant'), host_string=v.user_hostname_port(vm_name=target),
                      key_filename=v.keyfile(vm_name=target), disable_known_hosts=True):
            # this is necessary because `fpm` looks in a folder equally named like given with the -n option for setup.py to detect the correct version number of the resulting package
            file_link('/vagrant', '/vagrant/{0}'.format(p.basename))
            print 'build {0}.{1} on {2} ({3})'.format(p.basename, package_format, v.user_hostname_port(vm_name=target),
                                                      target)
            messages = sudo('fpm -s python --python-pypi http://{0}/simple/ -t {2} {3} --iteration {4}.{5} --force --name {1} "{1}"'.format(
                    env.repo_host,
                    p.basename,
                    package_format,
                    dependencies,
                    p.sha,
                    target))

            for message in messages.split('\n'):
                if 'Created package' in message:
                    setattr(p, package_format, message.split(':path=>')[1].replace('"', '').replace('}', ''))
                    break

            if not getattr(p, package_format):
                print 'error while creating {0} package'.fomat(package_format)
                continue
            file_link(getattr(p, package_format), '{0}.{1}.{2}'.format(p.sha, target, package_format))

        if getattr(p, package_format):
            v.halt(vm_name=target)
            execute('repo_{0}_add'.format(package_format), '{0}/{1}'.format(p.basename, getattr(p, package_format)),
                    target)
        else:
            print 'no package has been created, you may want to inspect the state in the machine:'
            print 'cd {0}/ && vagrant ssh {1}'.format(p.basename, target)
    print 'task ran {0} seconds'.format(time.time() - start_time)


@task
def build_pypi(repo, name=None):
    p = execute(git_checkout, repo, name)
    p = p['<local-only>']

    with lcd(p.basename):
        output = local('python setup.py sdist', capture=True)
        for line in output.split('\n'):
            if line.startswith('creating'):
                p.tgz = line.split(' ')[1].strip() + '.tar.gz'
                break

        if not p.tgz:
            abort('error while creating tar.gz package')
        local('ln -sf dist/{0} {1}.tar.gz'.format(p.tgz, p.sha))

        with settings(host_string=env.repo_host, user='root'):
            dir_ensure('{0}/{1}'.format(env.repo_pypi_root, p.basename), recursive=True, owner='www-data',
                       group='www-data')
            put('dist/{0}'.format(p.tgz), '{0}/{1}'.format(env.repo_pypi_root, p.basename))

        return p


@task
def git_checkout(repo, name=None):

    p = Package(repo, name=name)

    if not os.path.isdir(p.basename):
        repo = Repo.clone_from(p.repo, p.basename)
    else:
        repo = Repo(p.basename)
        # ensure that the remote "origin" is set to the correct url
        if 'origin' in [remote.name for remote in repo.remotes]:
            Remote.remove(repo, 'origin')
        Remote.add(repo, 'origin', p.repo)

    repo.remote().pull(refspec='master')
    commit = repo.commit()
    p.sha = commit.hexsha[:7]
    print 'updated repo for "{0}" to commit {1}'.format(p.basename, p.sha)
    return p

