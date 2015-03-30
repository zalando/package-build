FROM debian:wheezy

MAINTAINER soeren.koenig@zalando.de

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev python-setuptools build-essential git-curl curl lsb-release
RUN gem install --no-rdoc --no-ri fpm-cookery
RUN apt-get clean
