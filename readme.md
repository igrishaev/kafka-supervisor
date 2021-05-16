
# Kafka-Supervisor

[CI Pipeline](https://ci.internal.exoscale.ch/blue/organizations/jenkins/docker-kafka-supervisor/activity/)

[spotify-kafka]: https://github.com/spotify/docker-kafka

This image brings the standard, non-Confluent Kafka installation. The main
feature of the image is that all Zookeeper, Kafka and Connect are run within a
single container. Namelly, if you run it, you'll get all the three at once
without composing them manually out from separated images.

Although this approach breaks Docker best practices (one process -- one image),
it dramatically simplifies the installation. A typical `docker-compose.yml` for
Kafka takes a couple of screens whereas this image does most of work for
you. The idea was borrowed from a [Kafka image from Spotify][spotify-kafka] that
has been quite popular and got 1.4K stars so far in favor its
simplicity. Nowadays, the project is archived.

All the processes are served with Supervisor. For each subsystem, there is a
`.conf` file in the `docker/etc/supervisor/conf.d` directory. All the logs go to
the standard OUT/ERR channels.

The image exposes the standard 2181, 9092, and 8083 ports for interaction with
various Kafka subsystems.

The image is fully configurable with the env vars. We use the same approach that
they use in Confluent. Each var consist from a prefix and the rest part which
becomes a Kafka option. For example, a bunch of these vars:

```yaml
environment:
  CONNECT_PLUGIN_PATH: /kafka/plugins
  KAFKA_ADVERTISED_HOST_NAME: localhost
  KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
  KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
  KAFKA_LISTENERS: PLAINTEXT://:9092
```

will become the following Kafka options:

```
plugin.path = /kafka/plugins
advertised.host.name = localhost
advertised.listeners = PLAINTEXT://localhost:9092
auto.create.topics.enable = "true"
listeners = plaintext://:9092
```

A prefix might be one of `KAFKA_`, `ZOOKEEPER_`, and `CONNECT_`. The names get
transformed to lower case, underscores become dots. The initial script scans the
env vars and saturates corresponding `.property` files from the `/kafka/config`
directory with the values which names match the prefix.

Build a local image (check out the Makefile):

```
make docker-build
```

Run it as a Docker process:

```
docker run -it --rm -p 2181:2181 -p 9092:9092 -p 8083:8083 <image>
```

Pay attention, without configuring advertised hosts and listeners, Kafka's
behaviour is weird, e.g. you cannot create a topic, polling hangs, and so
on. Here is the list of recommended env vars on local machine:

```yaml
services:
  kafka:
    environment:
      CONNECT_PLUGIN_PATH: /kafka/plugins
      KAFKA_ADVERTISED_HOST_NAME: localhost
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
      KAFKA_LISTENERS: PLAINTEXT://:9092
```

On CI, you redefine some of them:

```yaml
services:
  kafka:
    environment:
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092
```

There is the `ENV` file in the repo which unites these settings.
