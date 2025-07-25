# syntax=docker/dockerfile:1.17.1@sha256:38387523653efa0039f8e1c89bb74a30504e76ee9f565e25c9a09841f9427b05
FROM tomcat:11.0@sha256:5cfc7100fef1f6f7a07c527524cdc99cd2c8af171a93e34c1c3eb513bd42e93e AS build

WORKDIR /build

ARG \
  MAVEN_VERSION=3.8.7-2

RUN apt-get update && \
  apt-get install -y maven="${MAVEN_VERSION}" --no-install-recommends

COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:11.0@sha256:5cfc7100fef1f6f7a07c527524cdc99cd2c8af171a93e34c1c3eb513bd42e93e

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /build/target/folio-shelving-order.war /usr/local/tomcat/webapps/
RUN mkdir -p /usr/local/tomcat/webapps/ROOT && \
    echo "OK" > /usr/local/tomcat/webapps/ROOT/healthz && \
    groupadd -f nobody && \
    useradd -r -s /bin/false -g nobody tomcat && \
    chown -R tomcat /usr/local/tomcat

USER tomcat

HEALTHCHECK CMD curl -f http://localhost:8080/healthz | grep -q OK
