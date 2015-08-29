# Usage

To run this docker container use the following command

```
docker run -d -p 8153:8153 -p 8154:8154 jsalverda/gocd-server:15.2.0
```

For setting up autoregistration for agents pass in the AGENT_KEY environment variable with a secret value

```
docker run -d -p 8153:8153 -p 8154:8154 -e "AGENT_KEY=388b633a88de126531afa41eff9aa69e" jsalverda/gocd-server:15.2.0
```

# Port offloading
Running gocd server on port 80 and 443 causes the agent to fail connecting to the server, see https://github.com/gocd/gocd/issues/1459. So for serving go on port 80 and 443 it's best to use a proxy in front of it, see http://www.go.cd/documentation/user/current/installation/configure_proxy.html.

# Environment variables

| Name                | Description                                                            | Default value |
| ------------------- | ---------------------------------------------------------------------- | ------------- |
| SERVER_MEM          | The -Xms value for the java vm                                         | 512m          |
| SERVER_MAX_MEM      | The -Xmx value for the java vm                                         | 1024m         |
| SERVER_MIN_PERM_GEN | The -XX:PermSize value for the java vm                                 | 128m          |
| SERVER_MAX_PERM_GEN | The -XX:MaxPermSize value for the java vm                              | 256m          |
| AGENT_KEY           | The secret key to set on the server for auto-registration of agents    |               |