FROM ubuntu:latest

LABEL Davids <yourEmail@abc.com>

#update and upgrade apt packages
RUN echo "Updating apt packages"
RUN apt-get update -qq
RUN echo "Upgrading apt packages"
RUN apt-get upgrade -qq

#install curl cmd
RUN apt install curl -y

RUN echo "Installing Java"
ARG JAVA_VERSION=jdk8u242-b08
ARG JAVA_BINARY_URL=https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/${JAVA_VERSION}/OpenJDK8U-jdk_x64_linux_hotspot_8u242b08.tar.gz
ARG JAVA_SHA=f39b523c724d0e0047d238eb2bb17a9565a60574cf651206c867ee5fc000ab43
RUN echo "Downloading java jdk"
RUN curl -LfsSo /tmp/openjdk.tar.gz ${JAVA_BINARY_URL} >> /dev/null && \
    \
    echo "Checking download with hash" && \
    echo "${JAVA_SHA} */tmp/openjdk.tar.gz" | sha256sum -c - >> /dev/null && \
    \
    echo "Create the java directory and change to it" && \
    mkdir -p /opt/java/openjdk >> /dev/null && \
    cd /opt/java/openjdk >> /dev/null && \
    \
    echo "Unziping Java" && \
    tar -xf /tmp/openjdk.tar.gz --strip-components=1 >> /dev/null && \
    \
    echo "Cleaning downloaded files" && \
    rm -rf /tmp/openjdk.tar.gz
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="/opt/java/openjdk/bin:$PATH"

RUN echo "Installing Maven"
ARG MAVEN_VERSION=3.6.3
ARG MAVEN_BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries
ARG MAVEN_SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
RUN echo "Creating Maven folder"
RUN mkdir -p /usr/share/maven /usr/share/maven/ref >> /dev/null && \
    \
    echo "Downloading Maven" && \
    curl -fsSL -o /tmp/apache-maven.tar.gz ${MAVEN_BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz >> /dev/null && \
    \
    echo "Checking download hash" && \
    echo "${MAVEN_SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - >> /dev/null && \
    \
    echo "Unziping Maven" && \
    tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 >> /dev/null && \
    \
    echo "Cleaning and setting links" && \
    rm -f /tmp/apache-maven.tar.gz && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
#Define environmental variables required by Maven, like Maven_Home directory and where the maven repo is located
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

RUN mkdir -p /opt/app
# Copy the file from your host to your current location
COPY . /opt/app
# Set the working directory
WORKDIR /opt/app
# Run the command inside your image filesystem
RUN mvn clean install

RUN echo "Installing payara"

# Inform Docker that the container is listening on the specified port at runtime.
#EXPOSE 8080

# Run the specified command within the container.
#CMD [ "executable" ]