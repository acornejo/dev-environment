#!/bin/bash
sudo docker run --rm -p 8080:8080 -v  ${HOME}:/home/coder/mount -it buildme
