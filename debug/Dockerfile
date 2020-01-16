FROM ubuntu

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
    && rm -rf /var/lib/apt/lists/* 

