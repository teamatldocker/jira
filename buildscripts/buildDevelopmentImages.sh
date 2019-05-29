#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  buildImage "$PRODUCT_SOFTWARE" "$VERSION_JIRA" "$VERSION_DEVELOPMENT-software"
  buildImage "$PRODUCT_CORE" "$VERSION_JIRA" "$VERSION_DEVELOPMENT-core"
  buildImage "$PRODUCT_SERVICE_DESK" "$VERSION_SERVICE_DESK" "$VERSION_DEVELOPMENT-servicedesk"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
