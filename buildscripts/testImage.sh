#!/bin/bash -x

set -o errexit    # abort script at first error

function testImage() {
  local tagname=$1
  local port=$2
  local iteration=0
  docker run -d -p $port:8080 --name=$tagname blacklabelops/jira:$tagname
  while ! curl -v http://localhost:$port
  do
      { echo "Exit status of curl: $?"
        echo "Retrying ..."
      } 1>&2
      if [ "$iteration" = '30' ]; then
        break
      else
        ((iteration=iteration+1))
      fi
      sleep 10
  done
  docker stop $tagname
}

testImage $1 $2
