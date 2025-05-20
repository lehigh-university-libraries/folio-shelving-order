# syntax=docker/dockerfile:1.5.1@sha256:d2d74ff22a0e47b21f4bbde337e2ac4cd0a02a2226ef79264878db3dc7e87df8
FROM tomcat:11.0@sha256:80585828cfe3aa2e12c231761b9f429c49a7a9c30987c6405af96faee57c70d3 AS build

WORKDIR /build

ARG \
  MAVEN_VERSION=3.8.7-2

RUN apt-get update && \
  apt-get install -y maven="${MAVEN_VERSION}" --no-install-recommends

COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM tomcat:11.0@sha256:80585828cfe3aa2e12c231761b9f429c49a7a9c30987c6405af96faee57c70d3

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /build/target/folio-shelving-order.war /usr/local/tomcat/webapps/
RUN mkdir -p /usr/local/tomcat/webapps/ROOT && \
    echo "OK" > /usr/local/tomcat/webapps/ROOT/healthz && \
    groupadd -f nobody && \
    useradd -r -s /bin/false -g nobody tomcat && \
    chown -R tomcat /usr/local/tomcat

USER tomcat

HEALTHCHECK CMD curl -f http://localhost:8080/healthz | grep -q OK
