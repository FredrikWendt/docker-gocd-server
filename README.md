# Usage

To build this docker container use the following command

```
docker build -t gocd-server:15.2.0 .
```

And to run this docker container

```
docker run -d -p 8153:8153 -p 8154:8154 jsalverda/gocd-server:15.2.0
```

# Port offloading

Running gocd server on port 80 and 443 causes the agent to fail connecting to the server, see https://github.com/gocd/gocd/issues/1459. But when that's fixed it's hopefully possible to run it with normal ports on the outside

```
docker run -d -p 80:8153 -p 443:8154 jsalverda/gocd-server:15.2.0
```