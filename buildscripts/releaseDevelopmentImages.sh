#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  pushImage "$VERSION_DEVELOPMENT-software"
  pushImage "$VERSION_DEVELOPMENT-core"
  pushImage "$VERSION_DEVELOPMENT-servicedesk"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
