FROM ubuntu:12.04
MAINTAINER soeren.koenig@zalando.de

ENV DIST ubuntu12.04
ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/usr/local/go/bin

# COPY .netrc /root/.netrc
COPY zalando/ /usr/share/ca-certificates/zalando/
 
RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get update
RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev python-setuptools build-essential git-core curl lsb-release
RUN apt-get clean

RUN curl -O https://storage.googleapis.com/golang/go1.4.2.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.4.2.linux-amd64.tar.gz

RUN gem install --no-rdoc --no-ri fpm-cookery

RUN echo 'zalando/zalando-service-combined.crt' >> '/etc/ca-certificates.conf'
RUN /usr/sbin/update-ca-certificates

