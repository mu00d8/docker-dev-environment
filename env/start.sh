#!/usr/bin/env bash

set -eu
set -o pipefail
cd $(dirname $0)

source config.sh
cd ..

function yes_no() {
    if [[ "$1" == "yes" || "$1" == "y" ]]; then
        return 0
    else
        return 1
    fi
}

container="$(docker ps --filter="name=$CONTAINER_NAME" --latest --quiet)"
if [[ -n "$container" ]]; then
    # Connec to already running container
    log_success "[+] Found running instance: $container, connecting..."
    cmd="docker start $container"
    log_success "[+] $cmd"
    $cmd > /dev/null
    # only if we are not on Mac, check if NO_TTY is set
    if [[ "$(uname)" != "Darwin" ]] && [[ -v NO_TTY ]]; then
        HAS_TTY=""
    else
        HAS_TTY="-t"
    fi
    cmd="docker exec -i $HAS_TTY --workdir /home/user/ $container zsh"
    log_success "[+] $cmd"
    $cmd
    exit 0
fi

touch "$PWD/data/bash_history"
touch "$PWD/data/zsh_history"
mkdir -p "$PWD/data/ccache"
mkdir -p "$PWD/data/vscode-data"

log_success "[+] Creating new container..."

mounts=""
log_success "[+] Using locally build image"
mounts+=" -v $PWD:/home/user/shared "

cmd="docker run -ti -d --privileged
    $mounts
    -v $PWD/data/zshrc:/home/user/.zshrc
    -v $PWD/data/zsh_history:/home/user/.zsh_history
    -v $PWD/data/bash_history:/home/user/.bash_history
    -v $PWD/data/init.vim:/home/user/.config/nvim/init.vim
    -v $PWD/data/ccache:/ccache
    -v $PWD/data/vscode-data:/home/user/.config/Code
    --mount type=tmpfs,destination=/tmp,tmpfs-mode=777
    --ulimit msgqueue=2097152000
    --shm-size=16G
    --net=host
    --name $CONTAINER_NAME
    "

if [[ ! -z "$SSH_AUTH_SOCK"  ]]; then
    log_success "[+] Forwarding ssh agent ($SSH_AUTH_SOCK -> /ssh-agent)"
    cmd+="-v $(readlink -f "$SSH_AUTH_SOCK"):/ssh-agent --env SSH_AUTH_SOCK=/ssh-agent"
fi

# Use local gitconfig if any
if [[ -f "/home/$USER/.gitconfig" ]]; then
    cmd+=" -v /home/$USER/.gitconfig:/home/user/.gitconfig"
fi

log_success "[+] Using $IMAGE_NAME as docker image"
cmd+=" ${IMAGE_NAME}"

log_success "[+] $(echo $cmd | xargs)"
container_id=$($cmd)

# Permission fixup since mounts are initially owned by root
echo "[+] Fixing permission of /home/user/.config"
docker exec "$container_id" sudo chown -R user:user /home/user/.config

log_success "[+] Rerun $0 to connect to the new container."
