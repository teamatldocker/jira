#!/usr/bin/env bash
#
# Start Docker container
#

set -o errexit    # abort script at first error
set -o pipefail   # return the exit status of the last command in the pipe
set -o nounset    # treat unset variables and parameters as an error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading scrips config...."
source $CUR_DIR/scripts.cfg

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

printf '%b\n' ":: Searching for "$CONTAINER_NAME" container..."
CONTAINER_ID=$(docker ps -qa --filter="name="$CONTAINER_NAME"")

if [ -z "$CONTAINER_ID" ]; then
  err ""$CONTAINER_NAME" not found"
fi

docker run -it --volumes-from ${CONTAINER_NAME} ${UTILITY_IMAGE} /bin/bash

success "Container manage successful."
