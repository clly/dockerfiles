# Default run in server mode on port 8080

# To get docker ipaddress of iperf server use: 
# docker inspect --format "{{ .NetworkSettings.IPAddress }}" iperf3-server

FROM ubuntu:latest

RUN apt-get update && apt-get install -y iperf3 && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

ENTRYPOINT ["iperf3"]
CMD [,"-s","-p","8080"]
