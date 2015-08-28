FROM debian:jessie

MAINTAINER Jorrit Salverda <jorrit.salverda@gmail.com>

ENV GO_VERSION 15.2.0-2248
ENV GO_SERVER_PORT 8153
ENV GO_SERVER_SSL_PORT 8154

# install dependencies
RUN apt-get update \
    && apt-get install -y \
        curl \
        git \
        openjdk-7-jre-headless \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -fSL "http://download.go.cd/gocd-deb/go-server-$GO_VERSION.deb" -o go-server.deb \
    && dpkg -i go-server.deb \
    && rm -rf go-server.db \
    && sed -i -e "s/DAEMON=Y/DAEMON=N/" /etc/default/go-server

# define mountable directories
VOLUME ["/var/lib/go-server/artifacts", "/var/lib/go-server/db/h2db", "/var/lib/go-server/plugins/external", "/var/lib/go-server/pipelines/flyweight", "/var/log/go-server", "/etc/go", "/var/go/.ssh"]

# expose ports
EXPOSE $GO_SERVER_PORT $GO_SERVER_SSL_PORT

# define default command
CMD chown -R go:go /var/lib/go-server; sed -i -e "s/GO_SERVER_PORT=8153/GO_SERVER=${GO_SERVER_PORT}/" /etc/default/go-server; sed -i -e "s/GO_SERVER_SSL_PORT=8154/GO_SERVER_SSL_PORT=${GO_SERVER_SSL_PORT}/" /etc/default/go-server; /usr/share/go-server/server.sh; exec tail -F /var/log/go-server/*