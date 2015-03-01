#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement
import os
import glob
from shutil import copy
from string import Template
import json
import time
import datetime
import re

from fabric.api import local, run, sudo, execute, put
from fabric.context_managers import settings, cd, lcd, hide
from fabric.decorators import task, hosts, with_settings
from fabric.utils import abort
from fabric.state import env
from fabric.colors import blue, green, red
from cuisine import package_ensure, dir_ensure, file_link, file_write
from git import Repo
from git.remote import Remote
import vagrant

env.disable_known_hosts = True

if hasattr(env, 'legacy'):
    env.repo_host = 'iftp.zalando.net'
    env.repo_deb_root = '/data/zalando/iftp.zalando.net/htdocs/repo/apt/'
    env.repo_rpm_root = '/data/zalando/iftp.zalando.net/htdocs/repo/rpm/'
    env.repo_pypi_root = '/data/zalando/iftp.zalando.net/htdocs/simple/'
else:
    env.repo_host = 'z-repo'
    env.repo_deb_root = '/data/zalando/data/repo.zalando/apt/'
    env.repo_rpm_root = '/data/zalando/data/repo.zalando/rpm/'
    env.repo_pypi_root = '/data/zalando/data/repo.zalando/pypi/'

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


def atoi(text):
    return int(text) if text.isdigit() else text


def natural_keys(text):
    '''
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (See Toothy's implementation in the comments)
    '''
    return [ atoi(c) for c in re.split('(\d+)', text) ]

def package_exists(path):
    if os.path.isfile(path):
        print 'package has already been build: {0}'.format(path)
        return True

    return False

# some repo_* commands must run as root, because sudo won't allow access to the GPG keyring

@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_rpm_init():
    ''' initialize package repo '''

    package_ensure('createrepo')
    dir_ensure('{0}/archive/'.format(env.repo_rpm_root), recursive=True)

    for dist, package_format in PACKAGE_FORMAT.items():
        if package_format == 'rpm':
            for component in RPM_COMPONENTS:
                for arch in RPM_ARCHS:
                    path = '/'.join([env.repo_rpm_root, dist, component, arch])
                    dir_ensure(path, recursive=True)
                    run('createrepo {0}'.format(path))


@hosts(env.repo_host)
@with_settings(hide('commands'))
@task
def repo_rpm_list(dist='centos6.5'):
    ''' list repo's packages '''

    output = run('cd {0} && find {1} -type f -name "*rpm"'.format(env.repo_rpm_root, dist))
    for line in output.split('\n'):
        if line:
            dist, component, arch, package = line.split('/')
            print '{0}: {1}'.format('|'.join([dist, component, arch]), package)


@hosts(env.repo_host)
@with_settings(hide('commands'), user='root')
@task
def repo_rpm_add(package, dist='centos6.5', component='base'):
    ''' upload and add a package file to the repo '''

    arch = 'x86_64'
    if any(map(lambda arch: arch in package, ['i386, i586, i686'])):
        arch = 'i386'

    put(package, '{0}/archive/'.format(env.repo_rpm_root))
    package = package.split('/')[-1]
    path = '/'.join([env.repo_rpm_root, dist, component, arch])
    run('cp {0}/archive/{1} {2}'.format(env.repo_rpm_root, package, path))
    output = run('createrepo {0}'.format(path))
    if output.succeeded:
        print green('added {0} to repo {1}'.format(package, dist))


@hosts(env.repo_host)
@with_settings(hide('commands'), user='root')
@task
def repo_rpm_del(packagename, dist='centos6.5', component='base'):
    ''' delete "packagename" from repo '''

    packagename = packagename.strip()
    if not packagename:
        abort('can not delete empty package name'.format(packagename))

    if not packagename.endswith('.rpm'):
        packagename += '*.rpm'

    path = '/'.join([env.repo_rpm_root, dist, component])
    run('find {0} -name "{1}" -exec mv {{}} {2}/archive/ \;'.format(path, packagename, env.repo_rpm_root))
    output = run('createrepo {0}'.format(path))
    if output.succeeded:
        print red('deleted {0} from repo {1}'.format(packagename, dist))


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_init():
    ''' initialize package repo '''

    file_write('/etc/apt/sources.list.d/aptly-repo.list', 'deb http://repo.aptly.info/ squeeze main')
    package_ensure('aptly')

    with open('aptly.conf.tmpl', 'r') as tf:
        template = Template(tf.read())

    for dist, package_format in PACKAGE_FORMAT.items():
        if package_format == 'deb':
            dir_ensure('{0}/archive/{1}'.format(env.repo_deb_root, dist), recursive=True)
            configfile = 'aptly-{0}.conf'.format(dist)
            with open(configfile, 'w') as fh:
                    content = template.safe_substitute(repo_root=env.repo_deb_root, release=dist)
                    fh.write(content)
            put(configfile, '/etc/aptly-{0}.conf'.format(dist))
            os.unlink(configfile)
            run('aptly -config=/etc/aptly-{0}.conf repo list --raw=true | grep -q {0} || aptly -config /etc/aptly-{0}.conf repo create {0}'.format(dist))

@hosts(env.repo_host)
@with_settings(hide('commands'))
def get_last_snapshot(dist='ubuntu12.04'):
    output = sudo('aptly -config=/etc/aptly-{0}.conf snapshot list -sort="time" -raw=true'.format(dist))
    return output.split('\n').pop()


@hosts(env.repo_host)
def republish(dist='ubuntu12.04', snapshot=False):
    with hide('commands'):
        if snapshot:
            print 'drop current publication of repo {0}, if existing'.format(green(dist))
            run('aptly -config=/etc/aptly-{0}.conf -architectures=i386,amd64,all publish drop {0}'.format(dist), warn_only=True)

            print 'drop snapshot from today, if existing'
            run('aptly -config=/etc/aptly-{0}.conf -architectures=i386,amd64,all snapshot drop $(date +%F)'.format(dist), warn_only=True)

            print 'create current snapshot'
            if run('aptly -config=/etc/aptly-{0}.conf -architectures=i386,amd64,all snapshot create $(date +%F) from repo {0}'.format(dist)).failed:
                return False

            print 'publish current snapshot'
            if run('aptly -config=/etc/aptly-{0}.conf -architectures=i386,amd64,all publish snapshot $(date +%F)'.format(dist)).failed:
                return False
        else:
            run('aptly -config=/etc/aptly-{0}.conf publish list -raw=true | grep -q {0} || aptly -config=/etc/aptly-{0}.conf publish repo -distribution={0} {0}'.format(dist), warn_only=True)
            if run('aptly -config=/etc/aptly-{0}.conf publish update {0}'.format(dist), warn_only=True).failed:
                return False

    return True


@hosts(env.repo_host)
@with_settings(hide('commands'))
@task
def repo_deb_list(dist='ubuntu12.04', snapshot=False):
    ''' list repo's packages '''

    if snapshot:
        last = get_last_snapshot(dist)
        output = sudo('aptly -config=/etc/aptly-{0}.conf snapshot show -with-packages {1}'.format(dist, last))
    else:
        output = sudo('aptly -config=/etc/aptly-{0}.conf repo show -with-packages {0}'.format(dist))
    for line in output.split('\n'):
        print line


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_add(package, dist='ubuntu12.04'):
    '''Upload and add package to an apt repo with given dist, defaults to ubuntu12.04

    Example:
    % fab repo_deb_add:myfoo.deb,dist=ubuntu14.04
    '''
    if not os.path.isfile(os.path.expanduser(package)):
        abort('could not upload {0}: file not found'.format(package))

    with hide('commands'):
        put(package, '{0}/archive/{1}'.format(env.repo_deb_root, dist))
        package = package.split('/')[-1]
        run('aptly -config=/etc/aptly-{0}.conf repo add -force-replace {0} {1}/archive/{0}/{2}'.format(dist, env.repo_deb_root,  package))

    if republish(dist):
        print green('added {0} to repo {1}'.format(package, dist))


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_del(packagename, dist='ubuntu12.04'):
    ''' delete "packagename" from repo '''

    with hide('commands'):
        run('aptly -config=/etc/aptly-{0}.conf repo remove {0} {1}'.format(dist, packagename))

    if republish(dist):
        print red('deleted {0} from repo {1}'.format(packagename, dist))

@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_rebuild(dist='ubuntu12.04'):
    ''' rebuild repository and re-import all packages '''

    run('rm -fr {0}/{1}/'.format(env.repo_deb_root, dist))
    repo_deb_init()
    run('find {0}/archive/{1}/ -name "*.deb" | sort -n | while read package; do dpkg -I $package >/dev/null && aptly -config=/etc/aptly-{1}.conf repo add -force-replace {1} $package; done'.format(env.repo_deb_root, dist))

    if republish(dist):
        print green('successfully rebuild repo for dist {0}'.format(dist))

@task
@with_settings(hide('commands'))
def package_info(package):
    ''' display metadata info for package file'''
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
        info['description'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{SUMMARY}} {0}'.format(package), capture=True)
        info['arch'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{ARCH}} {0}'.format(package), capture=True)
        info['release'] = local('rpm -qp --dbpath=/tmp --queryformat=%{{RELEASE}} {0}'.format(package), capture=True)

        dependencies = local('rpm -qpR {0}'.format(package), capture=True)
        for dependency in dependencies.split('\n'):
            info['dependencies'].append(dependency.strip())

    print json.dumps(info, indent=2)
    return info


@task
def build_package(repo, name=None):
    ''' build DEB and RPM packages from repo URL '''

    start_time = time.time()

    p = execute(build_pypi, repo, name)
    p = p['<local-only>']

    # put all files for the build host in place
    copy('Vagrantfile', p.basename)
    copy('boxes', p.basename)
    copy('build-recipe.sh', p.basename)
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

        if package_exists('{0}/{1}.{2}.{3}'.format(p.basename, p.date, target, package_format)):
            continue

        if dependencies:
            dependencies = '--no-auto-depends ' + ' '.join([' -d "{0}"'.format(d) for d in dependencies])

        v = vagrant.Vagrant(root=p.basename)

        if v.status(vm_name=target)[0].state == v.RUNNING:
            v.destroy(vm_name=target)

        print 'running "{0}" for machine {1} on root dir ./{2}'.format(blue('vagrant up'), green(target), p.basename)
        v.up(vm_name=target)

        with settings(cd('/vagrant'), host_string=v.user_hostname_port(vm_name=target),
                      key_filename=v.keyfile(vm_name=target), disable_known_hosts=True):
            # this is necessary because `fpm` looks in a folder equally named like given with the -n option for setup.py to detect the correct version number of the resulting package
            file_link('/vagrant', '/vagrant/{0}'.format(p.basename))
            print 'build a {1} of {0} on {2} ({3})'.format(blue(p.basename), package_format, v.user_hostname_port(vm_name=target), green(target))
            messages = sudo('fpm -s python --python-pypi http://{0}/simple/ -t {2} {3} --iteration {4}.{5} --force --name {1} "{1}"'.format(
                    env.repo_host,
                    p.basename,
                    package_format,
                    dependencies,
                    p.date,
                    target))

            for message in messages.split('\n'):
                if 'Created package' in message:
                    setattr(p, package_format, message.split(':path=>')[1].replace('"', '').replace('}', ''))
                    break

            if not getattr(p, package_format):
                print 'error while creating {0} package'.format(package_format)
                continue
            file_link(getattr(p, package_format), '{0}.{1}.{2}'.format(p.date, target, package_format))

        if getattr(p, package_format):
            v.halt(vm_name=target)
            execute('repo_{0}_add'.format(package_format), '{0}/{1}'.format(p.basename, getattr(p, package_format)), target)
        else:
            print 'no package has been created, you may want to inspect the state in the machine:'
            print 'cd {0}/ && vagrant ssh {1}'.format(p.basename, target)
        print
    print 'task ran {0} seconds'.format(time.time() - start_time)


@task
def build_pypi(repo, name=None):
    ''' build pypi package from repo URL '''
    p = execute(git_checkout, repo, name)
    p = p['<local-only>']

    if package_exists('{0}/{1}.tar.gz'.format(p.basename, p.date)):
        return p

    with lcd(p.basename):
        local('python setup.py sdist', capture=True)

    dirlisting = os.listdir('{0}/dist/'.format(p.basename))
    dirlisting.sort(key=natural_keys, reverse=True)
    for file in dirlisting:
        if file.endswith('.tar.gz'):
            p.tgz = file
            break

    if not p.tgz:
        abort('error while creating tar.gz package')

    with lcd(p.basename):
        local('ln -sf dist/{0} {1}.tar.gz'.format(p.tgz, p.date))

    with settings(host_string=env.repo_host, user='root'):
        dir_ensure('{0}/{1}'.format(env.repo_pypi_root, p.basename), recursive=True, owner='zalando',
                    group='zalando')
        put('{0}/dist/{1}'.format(p.basename, p.tgz), '{0}/{1}'.format(env.repo_pypi_root, p.basename))

    return p


@task
def git_checkout(repo, name=None):
    ''' clone / pull repo URL '''

    p = Package(repo, name=name)

    if not os.path.isdir(p.basename):
        repo = Repo.clone_from(p.repo, p.basename)
    else:
        repo = Repo(p.basename)
        # ensure that the remote "origin" is set to the correct url
        if 'origin' in [remote.name for remote in repo.remotes]:
            Remote.remove(repo, 'origin')
        Remote.add(repo, 'origin', p.repo)

    try:
        repo.remote().pull(refspec='master')
    except ValueError:
        pass
    commit = repo.commit()
    p.sha = commit.hexsha[:7]
    p.date = datetime.datetime.fromtimestamp(commit.committed_date).strftime('%Y%m%d%H%M')
    print 'updated repo for "{0}" to commit {1}, date {2}'.format(blue(p.basename), green(p.sha), green(p.date))
    return p
