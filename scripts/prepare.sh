#!/usr/bin/env bash
set -e

docker network create socky_proxy-net
docker network create caddy-net
