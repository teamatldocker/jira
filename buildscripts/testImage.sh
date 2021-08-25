#!/usr/bin/env bash

testImage() {
  set -o errexit

  local tag="$1"
  local containerName="jira.$tag"
  local networkName="jira_dockertestnet"

  # CircleCI does not (easily) allow exposing Docker ports so we always use port 8080
  local port=8080
  docker run --rm -d -p "$port":"$port" --network $networkName --name="$containerName" teamatldocker/jira:"$tag"

  local response
  set +e
  response=$(docker run --rm --network $networkName curlimages/curl curl -s -o /dev/null -I -w '%{http_code}' --retry-connrefuse --max-time 10 --retry 40 --retry-delay 20 --retry-max-time 600 http://"$containerName":"$port")
  set -e
  if [[ $response != 2* ]] && [[ $response != 3* ]]; then
    exit 1
  fi
  docker stop "$containerName"

}

main() {
  testImage "$1" "$2"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
