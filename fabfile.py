#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import with_statement

import os
from os.path import join as pj
from string import Template
import json
import time
import re
import yaml

from fabric.api import local, run, sudo, execute, put
from fabric.context_managers import settings, hide
from fabric.decorators import task, hosts, with_settings
from fabric.utils import abort
from fabric.state import env
from fabric.colors import green, red
from cuisine import package_ensure, dir_ensure, file_write
from distutils.util import strtobool

env.disable_known_hosts = True

PATH = os.path.dirname(os.path.abspath(__file__))
RPM_COMPONENTS = ['base', 'updates', 'extras']
RPM_ARCHS = ['i386', 'x86_64']
PACKAGE_FORMAT = {
    'centos6': 'rpm',
    'debian7': 'deb',
    'ubuntu12.04': 'deb',
    'ubuntu14.04': 'deb',
}

CONFIG_FILE = os.path.expanduser('~/.config/package-build.yaml')
if not os.path.isfile(CONFIG_FILE):
    abort('config file {} not found, aborting here'.format(CONFIG_FILE))
with open(CONFIG_FILE, 'r') as config_file:
    env.update(yaml.load(config_file)['env'])


def atoi(text):
    return (int(text) if text.isdigit() else text)


def natural_keys(text):
    '''
    alist.sort(key=natural_keys) sorts in human order
    http://nedbatchelder.com/blog/200712/human_sorting.html
    (See Toothy's implementation in the comments)
    '''

    return [atoi(c) for c in re.split('(\d+)', text)]


def package_exists(path):
    if os.path.isfile(path):
        print 'package has already been build: {}'.format(path)
        return True

    return False


def prep_bool_arg(arg):
    return bool(strtobool(str(arg)))


# some repo_* commands must run as root, because sudo won't allow access to the GPG keyring

@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_rpm_init():
    ''' initialize package repo '''

    package_ensure('createrepo')

    for dist, package_format in PACKAGE_FORMAT.items():
        if package_format == 'rpm':
            dir_ensure('{0}/archive/{1}'.format(env.repo_rpm_root, dist), recursive=True)
            for component in RPM_COMPONENTS:
                for arch in RPM_ARCHS:
                    path = pj(env.repo_rpm_root, dist, component, arch)
                    dir_ensure(path, recursive=True)
                    run('createrepo {}'.format(path))


@hosts(env.repo_host)
@with_settings(hide('commands'))
@task
def repo_rpm_list(dist='centos6'):
    ''' list repo's packages '''

    output = run('cd {0} && find {1} -type f -name "*rpm"'.format(env.repo_rpm_root, dist))
    for line in output.split('\n'):
        if line:
            dist, component, arch, package = line.split('/')
            print '{0}: {1}'.format('|'.join([dist, component, arch]), package)


@hosts(env.repo_host)
@with_settings(hide('commands'), user='root')
@task
def repo_rpm_add(package, dist='centos6', component='base'):
    '''Upload and add package to an apt repo, defaults to centos6'''

    arch = 'x86_64'
    if any(map(lambda arch: arch in package, ['i386, i586, i686'])):
        arch = 'i386'

    put(package, pj(env.repo_rpm_root, 'archive', dist))
    package = package.split('/')[-1]
    path = pj(env.repo_rpm_root, dist, component, arch)
    run('cp {0} {1}'.format(pj(env.repo_rpm_root, 'archive', dist, package), path))
    output = run('createrepo {0}'.format(path))
    if output.succeeded:
        print green('added {0} to repo {1}'.format(package, dist))


@hosts(env.repo_host)
@with_settings(hide('commands'), user='root')
@task
def repo_rpm_del(packagename, dist='centos6', component='base'):
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
            dir_ensure(pj(env.repo_deb_root, 'archive', dist), recursive=True)
            configfile = 'aptly-{0}.conf'.format(dist)
            with open(configfile, 'w') as fh:
                content = template.safe_substitute(repo_root=env.repo_deb_root, release=dist)
                fh.write(content)
            put(configfile, '/etc/aptly-{0}.conf'.format(dist))
            os.unlink(configfile)
            run('/usr/bin/aptly -config=/etc/aptly-{0}.conf repo list --raw=true | grep -q {0} \
                || /usr/bin/aptly -config /etc/aptly-{0}.conf repo create {0}'.format(dist))


@hosts(env.repo_host)
@with_settings(hide('commands'))
def get_last_snapshot(dist='ubuntu14.04'):
    output = sudo('/usr/bin/aptly -config=/etc/aptly-{0}.conf snapshot list -sort="time" -raw=true'.format(dist))
    return output.split('\n').pop()


@hosts(env.repo_host)
def republish(dist='ubuntu14.04', snapshot=False):
    with hide('commands'):
        if snapshot:
            print 'drop current publication of repo {0}, if existing'.format(green(dist))
            run('/usr/bin/aptly -config=/etc/aptly-{0}.conf -architectures=i386,amd64,all \
                   publish drop {0}'.format(dist),
                warn_only=True)

            print 'drop snapshot from today, if existing'
            run('/usr/bin/aptly -config=/etc/aptly-{0}.conf -architectures=i386,amd64,all \
                    snapshot drop $(date +%F)'.format(dist),
                warn_only=True)

            print 'create current snapshot'
            if run('/usr/bin/aptly -config=/etc/aptly-{0}.conf -architectures=i386,amd64,all \
                    snapshot create $(date +%F) from repo {0}'.format(dist)).failed:
                return False

            print 'publish current snapshot'
            if run('/usr/bin/aptly -config=/etc/aptly-{0}.conf -architectures=i386,amd64,all \
                    publish snapshot $(date +%F)'.format(dist)).failed:
                return False
        else:
            run('/usr/bin/aptly -config=/etc/aptly-{0}.conf \
                    publish list -raw=true | grep -q {0} || \
                 /usr/bin/aptly -config=/etc/aptly-{0}.conf \
                 publish repo -distribution={0} {0}'.format(dist),
                warn_only=True)
            if run('/usr/bin/aptly -config=/etc/aptly-{0}.conf \
                    publish update -force-overwrite {0}'.format(dist),
                   warn_only=True).failed:
                return False

    return True


@hosts(env.repo_host)
@with_settings(hide('commands'))
@task
def repo_deb_list(dist='ubuntu14.04', snapshot=False):
    ''' list repo's packages '''

    if snapshot:
        last = get_last_snapshot(dist)
        output = sudo('/usr/bin/aptly -config=/etc/aptly-{0}.conf snapshot show -with-packages {1}'.format(dist, last))
    else:
        output = sudo('/usr/bin/aptly -config=/etc/aptly-{0}.conf repo show -with-packages {0}'.format(dist))
    for line in output.split('\n'):
        print line


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_add(package, dist='ubuntu14.04'):
    '''Upload and add package to an apt repo, defaults to ubuntu14.04

    Example:
    % fab repo_deb_add:myfoo.deb,dist=ubuntu14.04
    '''

    if not os.path.isfile(os.path.expanduser(package)):
        abort('could not upload {0}: file not found'.format(package))

    with hide('commands'):
        put(package, '{0}/archive/{1}'.format(env.repo_deb_root, dist))
        package = package.split('/')[-1]
        run('/usr/bin/aptly -config=/etc/aptly-{0}.conf repo add -force-replace {0} {1}/archive/{0}/{2}'.format(dist,
            env.repo_deb_root, package))

    if republish(dist):
        print green('added {0} to repo {1}'.format(package, dist))


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_del(packagename, dist='ubuntu14.04'):
    ''' delete "packagename" from repo '''

    with hide('commands'):
        run('/usr/bin/aptly -config=/etc/aptly-{0}.conf repo remove {0} {1}'.format(dist, packagename))

    if republish(dist):
        print red('deleted {0} from repo {1}'.format(packagename, dist))


@hosts(env.repo_host)
@with_settings(user='root')
@task
def repo_deb_rebuild(dist='ubuntu14.04'):
    ''' rebuild repository and re-import all packages '''

    run('rm -fr {0}/{1}/'.format(env.repo_deb_root, dist))
    repo_deb_init()
    run('find {0}/archive/{1}/ -name "*.deb" \
            | sort -n \
            | while read package; do dpkg -I $package >/dev/null \
            && /usr/bin/aptly -config=/etc/aptly-{1}.conf \
            repo add -force-replace {1} $package; done'.format(env.repo_deb_root,
        dist))

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
def docker_build(dist=None, force=False):
    ''' build Docker image from ./docker/<dist>/Dockerfile '''

    force = prep_bool_arg(force)

    def build(dist, force):
        image_existing = False
        if not force:
            with settings(warn_only=True):
                image_existing = local('docker images | grep -q package_build/{dist}'.format(dist=dist)).succeeded

        if not image_existing:
            print '(re)building image {}...'.format(dist)
            local('docker build --tag=package_build/{dist} {path}/docker/{dist}/'.format(dist=dist, path=PATH))

    if dist:
        print 'building Docker image for {}...'.format(dist)
        builddir = pj(PATH, 'docker', dist)
        os.path.isdir(builddir) or abort('{} dir is not existing'.format(builddir))
        build(dist, force)
    else:
        print 'building Docker images for all distributions...'
        for entry in os.listdir(pj(PATH, 'docker')):
            if os.path.isdir(pj(PATH, 'docker', entry)):
                build(entry, force)


@task
def docker_run(dist=None, command=''):
    ''' run a command on a Docker container based on dist'''

    def run(dist, command):
        with settings(warn_only=True):
            cmd = 'docker run -v ${{PWD}}:/data package_build/{dist} {command}'.format(dist=dist, command=command)
            if local(cmd).failed:
                execute('docker_build', dist)
                local(cmd)

    if dist:
        run(dist, command)
    else:
        for root, dirs, files in os.walk('./docker/'):
            for dist in dirs:
                run(dist, command)


@task
def package_build(dist=None, recipe='', upload=False):
    ''' build packages from recipe for dist '''

    if dist:
        dists = [dist]
    else:
        dists = [d for d, _ in PACKAGE_FORMAT.items()]

    for dist in dists:
        start_time = time.time()
        execute('docker_run', dist, '/data/cook-recipe.sh {}'.format(recipe))

        for root, dirs, files in os.walk(pj(PATH, 'recipes')):
            for file in files:
                if file == 'lastbuild' and os.path.getmtime(pj(root, file)) >= start_time:
                    package_name = ''
                    with open(pj(root, file), 'r') as fh:
                        package_name = fh.readline().strip()
                        print('package_name: {}'.format(package_name))
                    if package_name:
                        package_format = package_name.split('.')[-1]
                        dist = root.split('/')[-1]
                        if upload:
                            execute('repo_{0}_add'.format(package_format), pj(root, package_name), dist)
        print 'task ran {0} seconds'.format(time.time() - start_time)
