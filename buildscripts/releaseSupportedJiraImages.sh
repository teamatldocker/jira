#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  pushImage "latest"
  pushImage "$VERSION_JIRA"
  pushImage "latest.de"
  pushImage "$VERSION_JIRA.de"
  pushImage "core"
  pushImage "core.$VERSION_JIRA"
  pushImage "core.de"
  pushImage "core.$VERSION_JIRA.de"
  pushImage "servicedesk"
  pushImage "servicedesk.$VERSION_SERVICE_DESK"
  pushImage "servicedesk.de"
  pushImage "servicedesk.$VERSION_SERVICE_DESK.de"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
