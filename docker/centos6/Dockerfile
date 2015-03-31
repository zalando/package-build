FROM centos:centos6
MAINTAINER soeren.koenig@zalando.de

ENV RELEASE centos6

COPY epel.repo /etc/yum.repos.d/
COPY zalando-service-combined.ca /etc/ssl/certs/

RUN yum install -y ruby ruby-devel rubygems python-setuptools make gcc tar rpm-build git curl
RUN gem install --no-rdoc --no-ri fpm-cookery
RUN yum clean all
RUN git config --global http.sslCAInfo /etc/ssl/certs/zalando-service-combined.ca 
