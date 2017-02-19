#!/bin/bash -x

function cleanContainer() {
  local container=$1
  docker rm -f -v $container || true
}

cleanContainer $1
