#!/usr/bin/env bash

DIR=$(dirname "$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo "$0")")
. "$DIR/latestVersions.cfg"
. "$DIR/productNames.cfg"
REPO="teamatldocker/jira"

buildImage() {
  set -x -o errexit -o pipefail

  local product="$1"
  local version="$2"
  local tag="$3"
  local language="${4:-en}"
  local country="${5:-US}"
  local dockerfile="${6:-Dockerfile}"
  local buildDate
  buildDate="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

  docker build \
    -t "$REPO:$tag" \
    --build-arg JIRA_PRODUCT="$product" \
    --build-arg JIRA_VERSION="$version" \
    --build-arg LANG_LANGUAGE="$language" \
    --build-arg LANG_COUNTRY="$country" \
    --build-arg BUILD_DATE="$buildDate" \
    -f "$dockerfile" .
}

tagImage() {
  set -o errexit

  docker tag "$REPO:$1" "$REPO:$2"
}

pushImage() {
  set -o errexit

  docker push "$REPO:$1"
}

cleanContainer() {
  set -x -o errexit -o pipefail

  docker rm -f -v "$1" || true
}
