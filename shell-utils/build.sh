#!/usr/bin/env bash

docker build -t clly/shell-utils:latest .

for tag in $dockerTags; do
    echo "Tagging clly/shell-utils with $tag"
    docker tag clly/shell-utils:latest clly/shell-utils:$tag
done

docker push -a clly/shell-utils
