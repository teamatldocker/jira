#!/usr/bin/env bash
#
# Download a log file from Docker container
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

readonly LOGS_DIR=${ROOT_DIR}/${LOGFILE_DIRECTORY}

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
printf '%b\n' " container found"
printf '%b\n' ""
printf '%b\n' ":: Downloading logs from container..."

# make sure logs directory exists
if [ ! -d "${LOGS_DIR}" ]; then
  mkdir -p ${LOGS_DIR}
fi

log_filename=${LOGFILE_FILE_PREFIX}-$(date +$FILE_TIMESTAMP).log
$(docker logs ${CONTAINER_ID} > ${LOGS_DIR}/${log_filename})
if [[ "$?" -ne 0 ]]; then
  err "Command 'docker logs' failed"
fi

printf '%b\n' " logs directory: ${LOGS_DIR}"
printf '%b\n' " log filename  : ${log_filename}"

success "Downloading complete successful."

