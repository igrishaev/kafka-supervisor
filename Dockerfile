# Zookeeper, Kafka and Connect within a single container
# provided by the supervisor process controller.

FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive

LABEL org.label-schema.vcs-url="https://github.com/igrishaev/kafka-supervisor"
LABEL org.label-schema.schema-version="1.0"

# Tools
RUN apt-get update -q
RUN apt-get install -y -q wget curl rlwrap

# Install Kafka
ARG KAFKA_VERSION=2.7.2
ARG SCALA_VERSION=2.13

ARG KAFKA_DIR=kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ARG KAFKA_TMP=/tmp/${KAFKA_DIR}.tgz

ARG KAFKA_URL=https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

RUN wget -q ${KAFKA_URL} -O ${KAFKA_TMP}
RUN tar xfz ${KAFKA_TMP} -C /
RUN mv /${KAFKA_DIR} /kafka
RUN rm ${KAFKA_TMP}

# Supervisor
RUN apt-get install -y supervisor

# Java
RUN apt-get install -y openjdk-11-jre-headless

# Cleanup
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Files
COPY docker /

# Install Clojure CLI
ARG CLJ_SCRIPT=linux-install-1.10.2.774.sh

RUN wget -q https://download.clojure.org/install/${CLJ_SCRIPT}
RUN chmod +x ${CLJ_SCRIPT}
RUN ./${CLJ_SCRIPT}

# Trigger loading deps
RUN clojure -e "1"

# Ports
EXPOSE 2181 9092 8083

# Main script
CMD ["/start.sh"]
