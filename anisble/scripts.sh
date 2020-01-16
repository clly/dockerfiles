#!/usr/bin/env bash

function ansible-playbook() {
    docker run --rm -it -v $SSH_AUTH_SOCK:$SSH_AUTH_SOCK -v $PWD:/ansible ansible-playbook "${@}"
}
