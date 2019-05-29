#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  cleanContainer "jira.$VERSION_DEVELOPMENT-software"
  cleanContainer "jira.$VERSION_DEVELOPMENT-core"
  cleanContainer "jira.$VERSION_DEVELOPMENT-servicedesk"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
