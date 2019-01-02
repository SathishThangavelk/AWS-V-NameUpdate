# Source from https://hub.docker.com/r/_/openjdk/
#             https://github.com/docker-library/openjdk/blob/master/8-jdk/alpine/Dockerfile

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
    echo '#!/bin/sh'; \
    echo 'set -e'; \
    echo; \
    echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
  } > /usr/local/bin/docker-java-home \
  && chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

# ENV JAVA_VERSION 8u151
# ENV JAVA_ALPINE_VERSION 8.151.12-r0 
# node:8.9.4-alpine Uses alpine 3.6 which supports jdk 8.131.11-r2 only
ENV JAVA_VERSION 8u131
ENV JAVA_ALPINE_VERSION 8.131.11-r2

RUN set -x \
  && apk add --no-cache \
    openjdk8="$JAVA_ALPINE_VERSION" \
  && [ "$JAVA_HOME" = "$(docker-java-home)" ]

######################################## JDK INSTALLATION ENDS ######################################################

######################################## GRADLE INSTALLATION STARTS ######################################################

RUN mkdir /usr/lib/gradle /app

ENV GRADLE_VERSION 4.2.1
ENV GRADLE_HOME /usr/lib/gradle/gradle-${GRADLE_VERSION}
ENV PATH ${PATH}:${GRADLE_HOME}/bin

WORKDIR /usr/lib/gradle
RUN set -x \
  && apk add --no-cache wget \
  && wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
  && unzip gradle-${GRADLE_VERSION}-bin.zip \
  && rm gradle-${GRADLE_VERSION}-bin.zip \
  && apk del wget

######################################## GRADLE INSTALLATION ENDS ######################################################

RUN apk --no-cache update && \
    apk --no-cache add python py-pip py-setuptools ca-certificates curl groff less zip bash libstdc++ jq && \
    pip --no-cache-dir install --upgrade --user awscli && \
    pip --no-cache-dir install --upgrade --user awsebcli && \
    pip --no-cache-dir install --upgrade --user boto3 && \
    rm -rf /var/cache/apk/*

RUN apk update && apk upgrade && \
    apk add --no-cache git openssh perl

ENV PATH "$PATH:~/.local/bin"

ADD deployment-scripts /opt/deployment-scripts
