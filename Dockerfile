# syntax=docker/dockerfile:1.29.0@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183
FROM tomcat:11.0@sha256:94e91501407ed6da44f0fce35e20808922fdab488d9a1643994bdcdd4335d1cc AS build

WORKDIR /build

ARG \
  MAVEN_VERSION=3.8.7-2

RUN apt-get update && \
  apt-get install -y maven="${MAVEN_VERSION}" --no-install-recommends

COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:11.0@sha256:94e91501407ed6da44f0fce35e20808922fdab488d9a1643994bdcdd4335d1cc

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /build/target/folio-shelving-order.war /usr/local/tomcat/webapps/

ARG \
    # renovate: datasource=repology depName=ubuntu_24_04/curl
    CURL_VERSION=8.5.0-2ubuntu10.16 \
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
