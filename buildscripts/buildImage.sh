#!/usr/bin/env bash

main() {
  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  buildImage "$1" "$2" "$3" "$4" "$5" "$6"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
