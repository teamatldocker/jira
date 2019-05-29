#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"
  . "$DIR/testImage.sh"

  docker network create jira_dockertestnet

  testImage "$VERSION_DEVELOPMENT-software" "8220"
  testImage "$VERSION_DEVELOPMENT-core" "8260"
  testImage "$VERSION_DEVELOPMENT-servicedesk" "8300"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
