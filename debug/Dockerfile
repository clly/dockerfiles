FROM ubuntu:latest

RUN apt-get update && \
    apt-get install -y curl \
        dnsutils \
        iputils-ping \
        iproute2 \
        netcat \
        socat \
        vim \
        wget \
        tzdata \
        postgresql-client \
    && rm -rf /var/lib/apt/lists/* 

