#!/bin/bash -x

set -o errexit    # abort script at first error

function testImage() {
  local tagname=$1
  local port=$2
  local iteration=0
  docker run -d --network jira_dockertestnet --name=jira.$tagname atldocker/jira:$tagname
  while ! docker run --rm --network jira_dockertestnet atldocker/jenkins-swarm curl http://jira.$tagname:8080
  do
      { echo "Exit status of curl (${iteration}): $?"
        echo "Retrying ..."
      } 1>&2
      if [ "$iteration" = '30' ]; then
        exit 1
      else
        ((iteration=iteration+1))
      fi
      sleep 10
  done
  docker stop jira.$tagname
}

testImage $1 $2
