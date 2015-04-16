FROM centos:centos6
MAINTAINER soeren.koenig@zalando.de

ENV DIST centos6

COPY epel.repo /etc/yum.repos.d/
COPY zalando-service-combined.ca /etc/ssl/certs/zalando-service-combined.pem
COPY zalando-service-combined.ca /etc/pki/ca-trust/source/anchors/zalando-service-combined.pem

ENV TIMEZONE Europe/Berlin
RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
RUN yum install -y ruby ruby-devel rubygems python-setuptools make gcc tar rpm-build git curl
RUN gem install --no-rdoc --no-ri fpm-cookery
RUN yum clean all

RUN /usr/bin/update-ca-trust
