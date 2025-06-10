# syntax=docker/dockerfile:1.16.0@sha256:e2dd261f92e4b763d789984f6eab84be66ab4f5f08052316d8eb8f173593acf7
FROM tomcat:11.0@sha256:d2f9bdcd5b35fc7da231df399a9cda0d49ff402053d47f008dcb499ef3bcf950 AS build

WORKDIR /build

ARG \
  MAVEN_VERSION=3.8.7-2

RUN apt-get update && \
  apt-get install -y maven="${MAVEN_VERSION}" --no-install-recommends

COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:11.0@sha256:d2f9bdcd5b35fc7da231df399a9cda0d49ff402053d47f008dcb499ef3bcf950

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /build/target/folio-shelving-order.war /usr/local/tomcat/webapps/
RUN mkdir -p /usr/local/tomcat/webapps/ROOT && \
    echo "OK" > /usr/local/tomcat/webapps/ROOT/healthz && \
    groupadd -f nobody && \
    useradd -r -s /bin/false -g nobody tomcat && \
    chown -R tomcat /usr/local/tomcat

USER tomcat

HEALTHCHECK CMD curl -f http://localhost:8080/healthz | grep -q OK
