#!/usr/bin/env bash
#
# Remove Docker container
#

set -o errexit    # abort script at first error
set -o pipefail   # return the exit status of the last command in the pipe
set -o nounset    # treat unset variables and parameters as an error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading container config...."
source $CUR_DIR/container.cfg

# Helper functions
err() {
  printf '%b\n' ""
  printf '%b\n' "\033[1;31m[ERROR] $@\033[0m"
  printf '%b\n' ""
  exit 1
} >&2

success() {
  printf '%b\n' ""
  printf '%b\n' "\033[1;32m[SUCCESS] $@\033[0m"
  printf '%b\n' ""
}


#------------------
# SCRIPT ENTRYPOINT
#------------------

printf '%b\n' ":: Searching for "$CONTAINER_NAME" docker container..."
CONTAINER_ID=$(docker ps -aq --filter="name="$CONTAINER_NAME"")

if [ -z "$CONTAINER_ID" ]; then
  err ""$CONTAINER_NAME" container not found"
fi

# TODO: clarify whether we need to notify when container is running or stopped
printf '%b\n' " container is found"
printf '%b\n' ""
printf '%b\n' ":: Killing running container..."

# kill running container
docker kill ${CONTAINER_NAME}

printf '%b\n' ""
printf '%b\n' ":: Removing container..."

# remove container
stopped=$(docker rm ${CONTAINER_NAME})
if [[ "$?" -ne 0 ]]; then
  err "Could not remove "$CONTAINER_NAME" container"
fi

printf '%b\n' ":: Searching for "$CONTAINER_NAME" container..."
CONTAINER_RETRY=$(docker ps -aq --filter="name="$CONTAINER_NAME"")


if [ ! -z "$CONTAINER_RETRY" ]; then
  err ""$CONTAINER_NAME" container removal failed"
fi

success "Removal complete successful."
