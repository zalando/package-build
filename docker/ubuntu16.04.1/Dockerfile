FROM package_build/ubuntu16.04
MAINTAINER soeren.koenig@zalando.de

ENV DIST ubuntu16.04
ENV DEBIAN_FRONTEND noninteractive
ENV PATH $PATH:/usr/local/go/bin

RUN apt-get build-dep -y --no-install-recommends --no-install-suggests nagios-nrpe
RUN ln -fs /usr/lib/x86_64-linux-gnu/libssl.so /usr/lib/libssl.so

