FROM ubuntu:14.04
MAINTAINER soeren.koenig@zalando.de

ENV DIST ubuntu14.04
ENV DEBIAN_FRONTEND noninteractive

COPY zalando-service-combined.ca /usr/share/ca-certificates/
 
RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get update
RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev python-setuptools build-essential git-core curl lsb-release 
RUN gem install --no-rdoc --no-ri fpm-cookery
RUN apt-get clean
RUN git config --global http.sslCAInfo /usr/share/ca-certificates/zalando-service-combined.ca 
