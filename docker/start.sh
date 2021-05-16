#!/bin/bash

cd /scripts

clojure -m properties KAFKA_     /kafka/config/server.properties
clojure -m properties ZOOKEEPER_ /kafka/config/zookeeper.properties
clojure -m properties CONNECT_   /kafka/config/connect-distributed.properties

cd /

supervisord -n
