#!/usr/bin/env bash

set -eu
set -o pipefail
cd $(dirname $0)

source config.sh
cd ..

log_success "[+] Building docker image"
if [[ "$(uname)" == "Darwin" ]]; then
    # if this is a Mac, don't pass USER_UID and USER_GID but use the Dockerfile's defaults
    docker build --build-arg NUM_JOBS=$(nproc) --target dev $@ -t $IMAGE_NAME .
else
    docker build --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" --build-arg NUM_JOBS=$(nproc) --target dev $@ -t $IMAGE_NAME .
fi
if [[ $? -ne 0 ]]; then
    log_error "[+] Error while building the docker image."
    exit 1
else
    log_success "[+] Docker image successfully build. Use ./env/start.sh and ./env/stop.sh to manage the containers lifecycle."
fi

exit 0
