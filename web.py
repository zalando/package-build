#!/usr/bin/env python
# -*- coding: utf-8 -*-

import atexit
from uuid import uuid4
from argparse import ArgumentParser

from flask import Flask
from flask import request
from apscheduler.scheduler import Scheduler

import fabfile
from sqlitequeue import SqliteQueue

app = Flask(__name__)
cron = Scheduler(daemon=True)
queue = SqliteQueue('/run/shm/queue')

# Explicitly kick off the background thread
cron.start()


class DelayedResult(object):

    def __init__(self, key):
        self.key = key
        self._rv = None


# @TODO: queue.get() is not implemented yet
#    @property
#    def return_value(self):
#        if self._rv is None:
#            rv = queue.get(self.key)
#            if rv is not None:
#                self._rv = loads(rv)
#        return self._rv
#

def queuefunc(f):

    def delay(*args, **kwargs):
        key = '%s:%s' % (f.__name__, str(uuid4()))
        item = f, key, args, kwargs
        queue.append(item)
        return DelayedResult(key)

    f.delay = delay
    return f


@cron.interval_schedule(seconds=10)
def queue_consumer():
    item = queue.popleft()
    func, key, args, kwargs = item
    try:
        rv = func(*args, **kwargs)
    except Exception, e:
        rv = e
    if rv is not None:
        print rv


@app.route('/build')
def build():
    project = request.args.get('project')
    dr = build_package.delay(project)
    return 'build for project "%s" has been enqueued with key "%s"' % (project, dr.key)


@queuefunc
def build_package(project):
    fabfile.build_package(project)

# Shutdown your cron thread if the web process is stopped
atexit.register(lambda : cron.shutdown(wait=False))

if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument('-d', '--debug', action='store_true', help='debug mode')
    parser.add_argument('-H', '--host', default='0.0.0.0', help='host to listen on')
    parser.add_argument('-p', '--port', default=8000, type=int, help='port to listen on')
    args = parser.parse_args()

    app.config.update(TESTING=args.debug, PROPAGATE_EXCEPTIONS=args.debug, TRAP_HTTP_EXCEPTIONS=args.debug)

    app.run(host=args.host, port=args.port, debug=args.debug)
