#!/usr/bin/env python
# -*- coding: utf-8 -*-

import atexit

from flask import Flask
from flask import request
from apscheduler.scheduler import Scheduler

from fabfile import build_package

app = Flask(__name__)
cron = Scheduler(daemon=True)
# Explicitly kick off the background thread
cron.start()

@app.route('/build')
def build():
    project = request.args.get('project')
    build_package(project)

@cron.interval_schedule(minutes=1)
def job_function():
    print 'running job_function ...'

# Shutdown your cron thread if the web process is stopped
atexit.register(lambda: cron.shutdown(wait=False))

if __name__ == '__main__':
    app.run()
