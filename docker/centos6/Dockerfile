FROM centos:centos6
MAINTAINER soeren.koenig@zalando.de

ENV DIST centos6
ENV PATH $PATH:/usr/local/go/bin:/opt/rh/ruby193/root/usr/local/bin

COPY epel.repo /etc/yum.repos.d/
COPY zalando-service-combined.ca /etc/pki/ca-trust/source/anchors/zalando-service-combined.pem

ENV TIMEZONE Europe/Berlin
RUN echo ZONE="$TIMEZONE" > /etc/sysconfig/clock && cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
RUN yum clean all
RUN yum install -y --noplugins python-setuptools python-devel python-pip make gcc tar rpm-build git curl mercurial centos-release-scl
RUN yum install -y --noplugins ruby193 ruby193-ruby-devel ruby193-rubygems

RUN curl -O https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.5.3.linux-amd64.tar.gz

COPY pip.conf /etc/pip.conf
RUN pip install --upgrade pip 
RUN pip install virtualenv virtualenv-tools

RUN echo "source /opt/rh/ruby193/enable" > /etc/profile.d/ruby193.sh
RUN source /opt/rh/ruby193/enable && gem install --no-rdoc --no-ri json_pure json --version 1.7.7
RUN source /opt/rh/ruby193/enable && gem install --no-rdoc --no-ri fpm --version 1.4.0
RUN source /opt/rh/ruby193/enable && gem install --no-rdoc --no-ri fpm-cookery

RUN /usr/bin/update-ca-trust
RUN /usr/bin/update-ca-trust enable

ADD http://repo.zalando/static/.netrc /root/.netrc
