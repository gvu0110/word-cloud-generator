FROM ubuntu:20.04

# Install openssh-server and python to support ansible
RUN apt-get update && apt-get install --no-install-recommends -y openssh-server python python3 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd && \
    mkdir /root/.ssh && \
    chmod 700 /root/.ssh && \
    touch /root/.ssh/authorized_keys

RUN echo 'root:P@ssW0rd!' | chpasswd

COPY sshd_config /etc/ssh/sshd_config

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]