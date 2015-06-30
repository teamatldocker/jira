#!/usr/bin/env bash
#
# Restore docker volume from a data container.
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

readonly BACKUP_DIR=${ROOT_DIR}/${BACKUP_DIRECTORY}
readonly RESTORE_CONTAINER="rst_from_volume"

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

usage() {
  printf '%b\n' ""
  printf '%b\n' "No backup archive provided."
  printf '%b\n' "Usage: restore.sh {path-to-backup-archive.tar}"
  printf '%b\n' ""
  exit 1
}

checkRunningRestore() {
  printf '%b\n' ":: Searching for running restore container..."
  CONTAINER_SEARCH=$(docker ps -q --filter="name="$RESTORE_CONTAINER"")

  if [ ! -z "$CONTAINER_SEARCH" ]; then
    printf '%b\n' " container is found"
    err "restore is already running"
  fi
}

cleaningBusybox() {
  printf '%b\n' ":: Searching for restore container..."
  CONTAINER_SEARCH=$(docker ps -aq --filter="name="$RESTORE_CONTAINER"")

  if [ ! -z "$CONTAINER_SEARCH" ]; then
    printf '%b\n' " restore container found"
    printf '%b\n' " cleaning container"
    # remove container
    docker rm ${RESTORE_CONTAINER}
  fi
}

#------------------
# SCRIPT ENTRYPOINT
#------------------
if [ $# == 0 ]; then
  usage
fi

printf '%b\n' ":: Searching for backup file..."
if [ ! -f $1 ]; then
  err "Backup archive '$1' is not found"
fi
backup_file=$1
printf '%b\n' " backup archive exists"
printf '%b\n' ""

printf '%b\n' ":: Searching for "$CONTAINER_NAME" container"
CONTAINER_ID=$(docker ps -aq --filter="name="$CONTAINER_NAME"")
if [ -z "$CONTAINER_ID" ]; then
  err ""$CONTAINER_NAME" container not found"
fi
printf '%b\n' " container found"
printf '%b\n' ""
printf '%b\n' ":: Restoring /"$CONTAINER_NAME" folder into container..."

# stop jenkins, because we cannot import in running container
printf '%b\n' " stop container if running"
stopped=$(docker stop ${CONTAINER_NAME})
if [[ "$?" -ne 0 ]]; then
  err "Could not stop "$CONTAINER_NAME" container"
fi

checkRunningRestore

cleaningBusybox

printf '%b\n' ":: Starting restore..."

$(docker run --name=""$RESTORE_CONTAINER"" --rm --volumes-from ${CONTAINER_NAME} -v $(pwd)/${backup_file}:/backup.tar busybox tar xf /backup.tar)
if [[ "$?" -ne 0 ]]; then
  err "Could not restore backup into "$CONTAINER_NAME" container"
fi

printf '%b\n' " backup imported into "$CONTAINER_NAME" container"
printf '%b\n' ""
printf '%b\n' ":: Starting "$CONTAINER_NAME" with restored data again..."
running=$(docker start ${CONTAINER_NAME})
if [[ "$?" -ne 0 ]]; then
  err "Could not start stopped "$CONTAINER_NAME" container"
fi

cleaningBusybox

success "Restoring of backups complete successfull."

