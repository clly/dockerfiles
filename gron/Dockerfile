# 
# Gron turns json into something that's easily greppable
# 
# gron "https://api.github.com/repos/tomnomnom/gron/commits?per_page=1" | fgrep "commit.author"
# json[0].commit.author = {};
# json[0].commit.author.date = "2016-07-02T10:51:21Z";
# json[0].commit.author.email = "mail@tomnomnom.com";
# json[0].commit.author.name = "Tom Hudson";
#
# to run: "echo {} | docker run --rm -i gron"
# in bash: 
#   alias gron="docker run --rm -i gron"
#   alias ungron="docker run --rm -i gron --ungron"

FROM golang:latest

RUN go get -u github.com/tomnomnom/gron

ENTRYPOINT ["gron"]
