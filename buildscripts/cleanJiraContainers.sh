#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  cleanContainer "jira.latest"
  cleanContainer "jira.$VERSION_JIRA"
  cleanContainer "jira.latest.de"
  cleanContainer "jira.$VERSION_JIRA.de"
  cleanContainer "jira.core"
  cleanContainer "jira.core.$VERSION_JIRA"
  cleanContainer "jira.core.de"
  cleanContainer "jira.core.$VERSION_JIRA.de"
  cleanContainer "jira.servicedesk"
  cleanContainer "jira.servicedesk.$VERSION_SERVICE_DESK"
  cleanContainer "jira.servicedesk.de"
  cleanContainer "jira.servicedesk.$VERSION_SERVICE_DESK.de"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
