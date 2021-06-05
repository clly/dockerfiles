#!/usr/bin/env python3

import fileinput, sys, json, os

images = []
files = os.listdir(".")
for f in files:
    # is a hidden dir
    if f[0] == ".":
        continue
    if os.path.isdir(f):
        if os.path.exists(f + "/Dockerfile"):
            images.append(f)
print(json.dumps(images))
