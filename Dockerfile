# syntax=docker/dockerfile:1.23.0@sha256:2780b5c3bab67f1f76c781860de469442999ed1a0d7992a5efdf2cffc0e3d769
FROM tomcat:11.0@sha256:931b145a361d3aa3033e97dd035dace2fe5bc551abfc5aaa0b341a2ac00e8b2f AS build

WORKDIR /build

ARG \
  MAVEN_VERSION=3.8.7-2

RUN apt-get update && \
  apt-get install -y maven="${MAVEN_VERSION}" --no-install-recommends

COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:11.0@sha256:931b145a361d3aa3033e97dd035dace2fe5bc551abfc5aaa0b341a2ac00e8b2f

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /build/target/folio-shelving-order.war /usr/local/tomcat/webapps/

ARG \
    # renovate: datasource=repology depName=ubuntu_24_04/curl
    CURL_VERSION=8.5.0-2ubuntu10.8 \
    # renovate: datasource=repology depName=ubuntu_24_04/less
    LESS_VERSION=590-2ubuntu2.1

RUN apt-get install -y --no-install-recommends \
    curl="${CURL_VERSION}" \
    less="${LESS_VERSION}" && \
    mkdir -p /usr/local/tomcat/webapps/ROOT && \
    echo "OK" > /usr/local/tomcat/webapps/ROOT/healthz && \
    groupadd -f nobody && \
    useradd -r -s /bin/false -g nobody tomcat && \
    chown -R tomcat /usr/local/tomcat

USER tomcat

HEALTHCHECK CMD curl -f http://localhost:8080/healthz | grep -q OK
