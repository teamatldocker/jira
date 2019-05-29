#!/usr/bin/env bash

main() {
  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  cleanContainer "$1"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
