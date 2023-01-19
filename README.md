# Docker Dev Environment

This repository contains convenience scripts to work with a dockerized environment, mostly to test fuzzing stuff.

## Usage

1) Clone this repository
2) Rename this repository
3) Set your project $NAME in [config.sh](env/config.sh)
4) Customize the Dockerfile and add your own fuzzer
5) Read instructions below on how to use the scripts


## Overview
This repository is structured as follows:

* [env](env) contains various convenience scripts to manage the lifecycle of the docker environment
* [data](data) contains default configuration files used for the docker environment


## Initial Build
The default Dockerfile will install a number of packages we found useful, Rust, and AFL++.
It will setup everything, such that the convenience scripts allow you to become the user "user".

```bash
# build image
./env/build.sh

# if you want to ignore the docker cache and build the whole image from scratch, run
./env/build.sh --no-cache
```


## Container Lifecycle
Once the container is built, you can manage the container lifecycle as follows:

```bash
# launch container
./env/start.sh

# run the same script again to connect
./env/start.sh

# stop (and delete) the container
./env/stop.sh

```

## Notes:
- when connecting to the container, you should be user "user" at /home/user
- sudo works passwordless
- everything in this directory is mounted as volume in the container (/home/user/shared), allowing to share data
