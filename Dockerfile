FROM debian:jessie

MAINTAINER Jorrit Salverda <jsalverda@travix.com>

# build time environment variables
ENV GO_VERSION 15.2.0-2248

# install dependencies
RUN apt-get update \
    && apt-get install -y \
        curl \
        git \
        openjdk-7-jre-headless \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN groupadd -r -g 999 go \
    && useradd -r -d /var/go -g go -u 999 go \
    && curl -fSL "http://download.go.cd/gocd-deb/go-server-$GO_VERSION.deb" -o go-server.deb \
    && dpkg -i go-server.deb \
    && rm -rf go-server.db \
    && sed -i -e "s/DAEMON=Y/DAEMON=N/" /etc/default/go-server

# define mountable directories
VOLUME ["/var/lib/go-server/artifacts", "/var/lib/go-server/db/h2db", "/var/lib/go-server/plugins/external", "/var/lib/go-server/pipelines/flyweight", "/var/log/go-server", "/etc/go", "/var/go/.ssh"]

# runtime environment variables
ENV SERVER_MEM 512m
ENV SERVER_MAX_MEM 1024m
ENV SERVER_MIN_PERM_GEN 128m
ENV SERVER_MAX_PERM_GEN 256m
ENV AGENT_KEY ""

# expose ports
EXPOSE 8153 8154

# define default command
CMD chown -R go:go /var/lib/go-server; chown -R go:go /var/log/go-server; chown -R go:go /etc/go; (/bin/su - go -c "/usr/share/go-server/server.sh &"); until curl -s -o /dev/null 'http://localhost:8153'; do sleep 1; done; if [ -n "$AGENT_KEY" ]]; then sed -i -e 's/agentAutoRegisterKey="[^"]*" *//' -e 's#\(<server\)\(.*artifactsdir.*\)#\1 agentAutoRegisterKey="'$AGENT_KEY'"\2#' /etc/go/cruise-config.xml; fi; exec tail -F /var/log/go-server/*