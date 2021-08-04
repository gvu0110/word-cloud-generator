FROM jenkins/jenkins:2.303

USER root

RUN \
    apt-get update && \
    apt-get install -y \
        build-essential \
        apt-utils \
        vim \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# To install docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh ./get-docker.sh

# To install docker-compose
RUN curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose

# To give jenkins docker rights
RUN usermod -aG docker jenkins

# To define plugins to be installed
COPY plugins.txt /usr/share/jenkins/plugins.txt

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

# Comment out to make Docker in Docker work in MacOS
#USER jenkins

# To suppress the signature verification check when using update server
ENV JAVA_OPTS=-Dhudson.model.DownloadService.noSignatureCheck=true