#!/usr/bin/env bash
#
# Build Docker image
#

set -o errexit    # abort script at first error
set -o pipefail   # return the exit status of the last command in the pipe
set -o nounset    # treat unset variables and parameters as an error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading scripts config...."
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

lookForImage() {
  local IMAGE_LIST=$(docker images | awk '{print $1}')
  local IMAGE_FOUND="false"
  
  for image in $IMAGE_LIST
  do
    if [ $image = $IMAGE_NAME ]; then
      IMAGE_FOUND="true"
    fi
  done

  echo $IMAGE_FOUND
}

#------------------
# SCRIPT ENTRYPOINT
#------------------

found=$(lookForImage)
if [ $found = "true" ]; then
  err ""$IMAGE_NAME" does exist, cannot build"
fi

printf '%b\n' ""
printf '%b\n' ":: Building image..."

docker build -t ${IMAGE_NAME} .

found=$(lookForImage)
if [ $found = "false" ]; then
  err ""$IMAGE_NAME" not found, build failed"
fi

success "Image build successfully."

