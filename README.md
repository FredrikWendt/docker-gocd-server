# jsalverda/gocd-server

A gocd-server container that can be controlled very well by its environment variables

[![Docker starts](https://img.shields.io/docker/stars/jsalverda/gocd-server.svg)](https://hub.docker.com/r/jsalverda/gocd-server/)
[![Docker pulls](https://img.shields.io/docker/pulls/jsalverda/gocd-server.svg)](https://hub.docker.com/r/jsalverda/gocd-server/)

# Usage

To run this docker container use the following command

```sh
docker run -d \
    -p 8153:8153 \
    -p 8154:8154 \
    jsalverda/gocd-server:latest
```

# Environment variables

In order to configure the server with other than default settings you can pass in the following environment variables

| Name                | Description                                                            | Default value |
| ------------------- | ---------------------------------------------------------------------- | ------------- |
| SERVER_MEM          | The -Xms value for the java vm                                         | 512m          |
| SERVER_MAX_MEM      | The -Xmx value for the java vm                                         | 1024m         |
| SERVER_MIN_PERM_GEN | The -XX:PermSize value for the java vm                                 | 128m          |
| SERVER_MAX_PERM_GEN | The -XX:MaxPermSize value for the java vm                              | 256m          |
| AGENT_KEY           | The secret key to set on the server for auto-registration of agents    |               |

For setting up autoregistration for agents pass in the AGENT_KEY environment variable with a secret value

```sh
docker run -d \
    -p 8153:8153 \
    -p 8154:8154 \
    -e "AGENT_KEY=388b633a88de126531afa41eff9aa69e" \
    jsalverda/gocd-server:latest
```

# Mounting volumes

In order to keep important data persisted over a restart and use ssh keys from the host machine you can mount the following directories

| Directory                              | Description                                                                              | Importance                                                                                                     |
| -------------------------------------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| /var/lib/go-server/artifacts           | The build and test artifacts are stored here                                             | Although you can recreate artifacts by re-running pipelines, this is very time-consuming, so better to persist |
| /var/lib/go-server/db/h2db             | The file-based database is stored here; make sure it's mapped to a fast drive            | Absolutely keep this backed up!                                                                                |
| /var/lib/go-server/plugins/external    | Any plugins from http://www.go.cd/community/plugins.html you want to run                 | Can be downloaded from http://www.go.cd/community/plugins.html                                                 |
| /var/lib/go-server/pipelines/flyweight | Version control repositories are checked out here to scan for changes; sees a lot of i/o | Is checked out automatically, but costs quite some time                                                        |
| /etc/go                                | The configuration of all pipelines, templates, environments and agents                   | Keep this backed up!                                                                                           |
| /var/log/go-server                     | All output logs go here, but there also written to standard out in the container         | Preferably collect logs from standard out                                                                      |
| /var/go/.ssh                           | The ssh keys to connect to version control systems like github and bitbucket             | As it's better not to embed these keys in the container you likely need to mount this                          |

Start the container like this to mount the volumes

```sh
docker run -d \
    -p 8153:8153 \
    -p 8154:8154 \
    -e "AGENT_KEY=388b633a88de126531afa41eff9aa69e" \
    -v /mnt/persistent-disk/gocd-server/artifacts:/var/lib/go-server/artifacts \
    -v /mnt/persistent-disk/gocd-server/db:/var/lib/go-server/db/h2db \
    -v /mnt/persistent-disk/gocd-server/plugins:/var/lib/go-server/plugins/external \
    -v /mnt/persistent-disk/gocd-server/flyweight:/var/lib/go-server/pipelines/flyweight \
    -v /mnt/persistent-disk/gocd-server/config:/etc/go \
    -v /mnt/persistent-disk/gocd-server/logs:/var/log/go-server \
    -v /mnt/persistent-disk/gocd-server/ssh:/var/go/.ssh \
    jsalverda/gocd-server:latest
```

To make sure the process in the container can read and write to those directories create a user and group with same gid and uid on the host machine

```sh
groupadd -r -g 999 go
useradd -r -g go -u 999 go
```

And then change the owner of the host directories

```sh
chown -R go:go /mnt/persistent-disk/gocd-server/artifacts
chown -R go:go /mnt/persistent-disk/gocd-server/db
chown -R go:go /mnt/persistent-disk/gocd-server/plugins
chown -R go:go /mnt/persistent-disk/gocd-server/flyweight
chown -R go:go /mnt/persistent-disk/gocd-server/config
chown -R go:go /mnt/persistent-disk/gocd-server/logs
chown -R go:go /mnt/persistent-disk/gocd-server/ssh
```

# Port offloading

Running gocd server on port 80 and 443 causes the agent to fail connecting to the server, see https://github.com/gocd/gocd/issues/1459. So for serving gocd server on port 80 and 443 it's best to use a proxy in front of it, see http://www.go.cd/documentation/user/current/installation/configure_proxy.html.
