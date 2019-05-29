#!/usr/bin/env bash

testImage() {
  set -o errexit

  local tag="$1"
  local port="$2"
  local iteration=0
  docker run -d --network jira_dockertestnet --name=jira."$tag" teamatldocker/jira:"$tag"
  while ! docker run --rm --network jira_dockertestnet tutum/curl curl http://jira."$tag":8080; do
    {
      echo "Exit status of curl (${iteration}): $?"
      echo "Retrying ..."
    } 1>&2
    if [ "$iteration" = '30' ]; then
      exit 1
    else
      ((iteration = iteration + 1))
    fi
    sleep 10
  done
  docker stop "jira.$tag"
}

main() {
  testImage "$1" "$2"
}

[[ ${BASH_SOURCE[0]} == "$0" ]] && main "$@"
