FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
        ansible \
        sshpass && \
    rm -Rf /var/lib/apt/lists/* && \
    rm -Rf /usr/share/doc && rm -Rf /usr/share/man && \
    apt-get clean

COPY ansible.cfg /etc/ansible/ansible.cfg

COPY main.yml /etc/ansible/main.yml

COPY hosts.yml /etc/ansible/hosts.yml

CMD ["/bin/bash", "-c"]