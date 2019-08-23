#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  case "$1" in

    "$PRODUCT_SOFTWARE")
      pushImage "latest"
      pushImage "$VERSION_JIRA"
      pushImage "latest.de"
      pushImage "$VERSION_JIRA.de"
      ;;

    "$PRODUCT_CORE")
      pushImage "core"
      pushImage "core.$VERSION_JIRA"
      pushImage "core.de"
      pushImage "core.$VERSION_JIRA.de"
      ;;

    "$PRODUCT_SERVICE_DESK")
      pushImage "servicedesk"
      pushImage "servicedesk.$VERSION_SERVICE_DESK"
      pushImage "servicedesk.de"
      pushImage "servicedesk.$VERSION_SERVICE_DESK.de"
      ;;
    *)
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
      ;;
  esac
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
