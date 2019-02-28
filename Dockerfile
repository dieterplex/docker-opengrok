FROM ubuntu:16.04
MAINTAINER d1t2 "dieterplex@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
ENV OPENGROK_FLUSH_RAM_BUFFER_SIZE "-m 256"
ENV OPENGROK_INSTANCE_BASE /opengrok
ENV OPENGROK_TOMCAT_BASE /var/lib/tomcat8
ENV OPENGROK_WEBAPP_CFGADDR localhost:8080
ENV TERM xterm-color

ADD readonly_configuration.xml /etc/readonly_configuration.xml
ADD run.sh /rungrok

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
                    openjdk-8-jre-headless exuberant-ctags git subversion mercurial \
                    tomcat8 libtcnative-1 curl inotify-tools libarchive-tools \

RUN mkdir /opengrok \
 && wget -O - https://github.com/OpenGrok/OpenGrok/files/467358/opengrok-0.12.1.6.tar.gz.zip \
  | bsdtar xOf - \
  | tar zxvf - -C /opengrok --strip-components=1

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["/rungrok"]

EXPOSE 8080
