#!/usr/bin/env bash

testImage() {
  set -o errexit

  local tag="$1"
  local containerName="jira.$tag"
  local networkName="jira_dockertestnet"
  docker run --rm -d --network $networkName --name="$containerName" teamatldocker/jira:"$tag"

  local iteration=0
  while true; do
    local response
    set +e
    # CircleCI does not (easily) allow exposing Docker ports so we always use port 8080
    response=$(docker run --rm --network $networkName byrnedo/alpine-curl -s -o /dev/null -I -w '%{http_code}' http://"$containerName":8080)
    set -e
    if [[ $response == 2* ]] || [[ $response == 3* ]]; then
      break
    elif [[ $iteration == 10 ]]; then
      exit 1
    else
      ((iteration++))
      echo "HTTP status of iteration $iteration: $response"
      echo "Will wait and retry ..."
    fi
    sleep 10
  done
  docker stop "$containerName"

}

main() {
  testImage "$1" "$2"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
