# syntax=docker/dockerfile:1.27.0@sha256:bde3983e9c939224420ddaf6b784cc30e09b035a4dea01f581230c50809f372e
FROM tomcat:11.0@sha256:b4237a8551b327a88d67c156a943e2db14eb2bcbaa85cbfebd587e0cab9c8885 AS build

WORKDIR /build

ARG \
  MAVEN_VERSION=3.8.7-2

RUN apt-get update && \
  apt-get install -y maven="${MAVEN_VERSION}" --no-install-recommends

COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:11.0@sha256:b4237a8551b327a88d67c156a943e2db14eb2bcbaa85cbfebd587e0cab9c8885

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /build/target/folio-shelving-order.war /usr/local/tomcat/webapps/

ARG \
    # renovate: datasource=repology depName=ubuntu_24_04/curl
    CURL_VERSION=8.5.0-2ubuntu10.8 \
    # renovate: datasource=repology depName=ubuntu_24_04/less
    LESS_VERSION=590-2ubuntu2.1

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl="${CURL_VERSION}" \
    less="${LESS_VERSION}" && \
    rm -rf /var/lib/apt/lists && \
    mkdir -p /usr/local/tomcat/webapps/ROOT && \
    echo "OK" > /usr/local/tomcat/webapps/ROOT/healthz && \
    groupadd -f nobody && \
    useradd -r -s /bin/false -g nobody tomcat && \
    chown -R tomcat /usr/local/tomcat

USER tomcat

HEALTHCHECK CMD curl -f http://localhost:8080/healthz | grep -q OK
