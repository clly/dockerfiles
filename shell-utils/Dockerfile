FROM golang:latest as go-build

ENV GOBIN=/opt/bin/

RUN go get -u github.com/honeycombio/honeyvent

FROM ubuntu:latest

COPY --from=go-build /opt/bin/honeyvent /opt/bin/honeyvent


RUN apt-get update && apt-get install -y \
    curl apt-transport-https ca-certificates git socat \
    &&  curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list \
 && apt-get update && apt-get install -y \
    kubectl \
 && rm -rf /var/lib/apt/lists/*

ENV PATH=$PATH:/opt/bin
