FROM jsalverda/base:jessie-git-jre-7

MAINTAINER Jorrit Salverda

# build time environment variables
ENV GO_VERSION 15.2.0-2248
ENV USER_NAME go
ENV USER_ID 999
ENV GROUP_NAME go
ENV GROUP_ID 999

# install go server
RUN groupadd -r -g $GROUP_ID $GROUP_NAME \
    && useradd -r -g $GROUP_NAME -u $USER_ID -d /var/go $USER_NAME \
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
CMD groupmod -g ${GROUP_ID} ${GROUP_NAME}; usermod -g ${GROUP_ID} -u ${USER_ID} ${USER_NAME}; chown -R ${USER_NAME}:${GROUP_NAME} /var/lib/go-server; chown -R ${USER_NAME}:${GROUP_NAME} /var/log/go-server; chown -R ${USER_NAME}:${GROUP_NAME} /etc/go; (/bin/su - ${USER_NAME} -c "/usr/share/go-server/server.sh &"); until curl -s -o /dev/null 'http://localhost:8153'; do sleep 1; done; if [ -n "$AGENT_KEY" ]]; then sed -i -e 's/agentAutoRegisterKey="[^"]*" *//' -e 's#\(<server\)\(.*artifactsdir.*\)#\1 agentAutoRegisterKey="'$AGENT_KEY'"\2#' /etc/go/cruise-config.xml; fi; exec tail -F /var/log/go-server/*