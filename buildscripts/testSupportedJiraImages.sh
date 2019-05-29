#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"
  . "$DIR/testImage.sh"

  docker network create jira_dockertestnet

  testImage "latest" "8220"
  testImage "$VERSION_JIRA" "8230"
  testImage "latest.de" "8240"
  testImage "$VERSION_JIRA.de" "8250"
  testImage "core" "8260"
  testImage "core.$VERSION_JIRA" "8270"
  testImage "core.de" "8280"
  testImage "core.$VERSION_JIRA.de" "8290"
  testImage "servicedesk" "8300"
  testImage "servicedesk.$VERSION_SERVICE_DESK" "8310"
  testImage "servicedesk.de" "8320"
  testImage "servicedesk.$VERSION_SERVICE_DESK.de" "8330"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
