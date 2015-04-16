FROM ubuntu:12.04
MAINTAINER soeren.koenig@zalando.de

ENV DIST ubuntu12.04
ENV DEBIAN_FRONTEND noninteractive

COPY zalando/ /usr/share/ca-certificates/zalando/
 
RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get update
RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev python-setuptools build-essential git-core curl lsb-release
RUN apt-get clean

RUN gem install --no-rdoc --no-ri fpm-cookery

RUN echo 'zalando/zalando-service-combined.crt' >> '/etc/ca-certificates.conf'
RUN /usr/sbin/update-ca-certificates

