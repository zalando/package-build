FROM ubuntu:12.04
MAINTAINER soeren.koenig@zalando.de

ENV DIST ubuntu12.04
ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/usr/local/go/bin

COPY zalando/ /usr/share/ca-certificates/zalando/
 
RUN echo Europe/Berlin > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt-get update
RUN apt-get install -y ruby1.9.1 ruby1.9.1-dev python-setuptools python-dev python-pip build-essential git-core curl lsb-release unzip mercurial
RUN apt-get clean

RUN curl -O https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.5.3.linux-amd64.tar.gz

COPY pip.conf /etc/pip.conf
RUN pip install --upgrade pip 
RUN pip install virtualenv virtualenv-tools

RUN gem install --no-rdoc --no-ri json_pure --version 1.7.7
RUN gem install --no-rdoc --no-ri fpm-cookery

RUN echo 'zalando/zalando-service-combined.crt' >> '/etc/ca-certificates.conf'
RUN /usr/sbin/update-ca-certificates

ADD http://repo.zalando/static/.netrc /root/.netrc
