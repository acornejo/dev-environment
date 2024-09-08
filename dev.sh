#!/bin/bash
HUB_REPO="acornejo/dev-environment"
LABEL="buildme"
case $1 in
  run)
    sudo docker run --rm -p 8080:8080 --device /dev/snd -v  ${HOME}:/home/coder/mount -it ${LABEL}
    ;;
  build)
    sudo docker build -t ${LABEL} .
    ;;
  push)
    sudo docker tag ${LABEL} ${HUB_REPO}
    sudo docker push ${HUB_REPO}
    ;;
  pull)
    sudo docker pull ${HUB_REPO}
    sudo docker tag ${HUB_REPO} ${LABEL}
    ;;
  help)
    echo "Usage: $0 run|build|push|pull"
    ;;
  *)
    echo "Unknown command '$1'"
    echo "Try running $0 help"
    ;;
esac
