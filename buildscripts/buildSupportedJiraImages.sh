#!/usr/bin/env bash

main() {
  set -x

  local DIR
  DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
  . "$DIR/dockerFunctions.sh"

  case "$1" in

    "$PRODUCT_SOFTWARE")
      buildSoftware
      ;;

    "$PRODUCT_CORE")
      buildCore
      ;;

    "$PRODUCT_SERVICE_DESK")
      buildServiceDesk
      ;;
    *)
      buildSoftware
      buildCore
      buildServiceDesk
      ;;
  esac
}

buildSoftware() {
  local tag="latest"
  local product="$PRODUCT_SOFTWARE"
  local version="$VERSION_JIRA"

  buildImage "$product" "$version" "$tag"
  tagImage "$tag" "$version"

  buildImage "$product" "$version" "$tag.de" "de" "DE"
  tagImage "$tag.de" "$version.de"
}

buildCore() {
  local tag="core"
  local product="$PRODUCT_CORE"
  local version="$VERSION_JIRA"

  buildImage "$product" "$version" "$tag"
  tagImage "$tag" "$tag.$version"

  buildImage "$product" "$version" "$tag.de" "de" "DE"
  tagImage "$tag.de" "$tag.$version.de"
}

buildServiceDesk() {
  local tag="servicedesk"
  local product="$PRODUCT_SERVICE_DESK"
  local version="$VERSION_SERVICE_DESK"

  buildImage "$product" "$version" "$tag"
  tagImage "$tag" "$tag.$version"

  buildImage "$product" "$version" "$tag.de" "de" "DE"
  tagImage "$tag.de" "$tag.$version.de"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
