#!/usr/bin/env bash
#
# Backup docker volume ["/jenkins"] from docker container.
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
readonly BACKUP_CONTAINER="bckp_for_volume"

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

checkRunningBackup() {
  printf '%b\n' ":: Searching for running backup container..."
  CONTAINER_SEARCH=$(docker ps -q --filter="name="$BACKUP_CONTAINER"")

  if [ ! -z "$CONTAINER_SEARCH" ]; then
    printf '%b\n' " container is found"
    err "backup is already running"
  fi
}

cleaningBusybox() {
  printf '%b\n' ":: Searching for backup container..."
  CONTAINER_SEARCH=$(docker ps -aq --filter="name="$BACKUP_CONTAINER"")

  if [ ! -z "$CONTAINER_SEARCH" ]; then
    printf '%b\n' " backup container found"
    printf '%b\n' " cleaning container"
    # remove container
    docker rm ${BACKUP_CONTAINER}
  fi
}

#------------------
# SCRIPT ENTRYPOINT
#------------------

printf '%b\n' ":: Searching for "$CONTAINER_NAME" docker container..."
CONTAINER_ID=$(docker ps -aq --filter="name="$CONTAINER_NAME"")

if [ -z "$CONTAINER_ID" ]; then
  err ""$CONTAINER_NAME" container not found"
fi

printf '%b\n' " container found"
printf '%b\n' ""
printf '%b\n' ":: Backuping "$CONTAINER_VOLUME" folder from container..."

# make sure backups directory exists
if [ ! -d "${BACKUP_DIR}" ]; then
  err ""$BACKUP_DIR" not found"
fi

checkRunningBackup

cleaningBusybox

printf '%b\n' ":: Starting backup..."

backup_filename=${BACKUP_FILE_PREFIX}-$(date +$FILE_TIMESTAMP).tar
$(docker run --name=""$BACKUP_CONTAINER"" --rm --volumes-from ${CONTAINER_NAME} -v ${BACKUP_DIR}:/backup busybox tar cf /backup/${backup_filename} ${CONTAINER_VOLUME})
if [[ "$?" -ne 0 ]]; then
  err "Backup failed"
fi

cleaningBusybox

printf '%b\n' " backup directory: ${BACKUP_DIR}"
printf '%b\n' " backup file     : ${backup_filename}"

success "Backup complete"

