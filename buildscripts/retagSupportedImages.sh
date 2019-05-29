#!/usr/bin/env bash

main() {
  set -x -o errexit

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  readonly RETAG_REPOSITORY=$1
  readonly PUSH_VERSION=$JIRA_VERSION
  readonly PUSH_SERVICE_DESK_VERSION=$JIRA_SERVICE_DESK_VERSION

  retagImage latest $RETAG_REPOSITORY
  retagImage $PUSH_VERSION $RETAG_REPOSITORY
  retagImage latest.de $RETAG_REPOSITORY
  retagImage $PUSH_VERSION.de $RETAG_REPOSITORY
  retagImage core $RETAG_REPOSITORY
  retagImage core.$PUSH_VERSION $RETAG_REPOSITORY
  retagImage core.de $RETAG_REPOSITORY
  retagImage core.$PUSH_VERSION.de $RETAG_REPOSITORY
  retagImage servicedesk $RETAG_REPOSITORY
  retagImage servicedesk.$PUSH_SERVICE_DESK_VERSION $RETAG_REPOSITORY
  retagImage servicedesk.de $RETAG_REPOSITORY
  retagImage servicedesk.$PUSH_SERVICE_DESK_VERSION.de $RETAG_REPOSITORY
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
