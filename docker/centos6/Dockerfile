FROM centos:centos6
MAINTAINER soeren.koenig@zalando.de

ENV DIST centos6
ENV PATH $PATH:/usr/local/go/bin

COPY .netrc /root/.netrc
COPY epel.repo /etc/yum.repos.d/
COPY zalando-service-combined.ca /etc/ssl/certs/zalando-service-combined.pem
COPY zalando-service-combined.ca /etc/pki/ca-trust/source/anchors/zalando-service-combined.pem

ENV TIMEZONE Europe/Berlin
RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
RUN yum install -y ruby ruby-devel rubygems python-setuptools make gcc tar rpm-build git curl
RUN yum clean all

RUN curl -O https://storage.googleapis.com/golang/go1.4.1.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.4.1.linux-amd64.tar.gz

RUN gem install --no-rdoc --no-ri fpm-cookery

RUN /usr/bin/update-ca-trust
