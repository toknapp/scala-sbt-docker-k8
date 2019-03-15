#
# Scala and sbt Dockerfile
# Taken from:
# https://github.com/hseeberger/scala-sbt
#

# Pull base image
FROM openjdk:11.0.2

# Env variables
ENV SCALA_VERSION 2.12.8
ENV SBT_VERSION 1.2.8

# Scala expects this file
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

# Install Scala
## Piping curl directly in tar
RUN \
  curl -fsL https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  echo >> /root/.bashrc && \
  echo "export PATH=~/scala-$SCALA_VERSION/bin:$PATH" >> /root/.bashrc

# Install sbt
RUN \
  curl -L -o sbt-$SBT_VERSION.deb https://dl.bintray.com/sbt/debian/sbt-$SBT_VERSION.deb && \
  dpkg -i sbt-$SBT_VERSION.deb && \
  rm sbt-$SBT_VERSION.deb && \
  apt-get update && \
  apt-get install sbt && \
  sbt sbtVersion && \
  mkdir project && \
  echo "scalaVersion := \"${SCALA_VERSION}\"" > build.sbt && \
  echo "sbt.version=${SBT_VERSION}" > project/build.properties && \
  echo "case object Temp" > Temp.scala && \
  sbt compile && \
  rm -r project && rm build.sbt && rm Temp.scala && rm -r target

#
RUN \
    apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get install -y lsb-release build-essential apt-transport-https ca-certificates curl gnupg2 software-properties-common

# GCloud
RUN \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    ## Add the Cloud SDK distribution URI as a package source
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    ## Import the Google Cloud Platform public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    apt-key fingerprint 0EBFCD88 && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-get remove -y docker docker-engine docker.io && \
    apt-get install -y google-cloud-sdk kubectl docker-ce && \
    usermod -aG docker root

# Define working directory
WORKDIR /root
