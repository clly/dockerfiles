#!/bin/bash

for i in *; do
    if [[ -d $i ]]; then
        if [[ -f $i/build.sh && -f $i/Dockerfile ]]; then
            echo "Building docker image $i"
            bash -c "cd $i; ./build.sh"
            echo
            echo "Successful!"
            echo
        fi
    fi
done
