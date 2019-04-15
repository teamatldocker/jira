#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly PUSH_REPOSITORY=$1
readonly PUSH_VERSION=$JIRA_VERSION
readonly PUSH_SERVICE_DESK_VERSION=$JIRA_SERVICE_DESK_VERSION
readonly PUSH_DEVELOPMENT_TAG=$JIRA_DEVELOPMENT_TAG

function retagImage() {
  local tagname=$1
  local repository=$2
  docker tag -f atldocker/jira:$tagname $repository/atldocker/jira:$tagname
}

function pushImage() {
  local tagname=$1
  local repository=$2

  docker push atldocker/jira:$tagname
}

pushImage $PUSH_DEVELOPMENT_TAG-software $PUSH_REPOSITORY
pushImage $PUSH_DEVELOPMENT_TAG-core $PUSH_REPOSITORY
pushImage $PUSH_DEVELOPMENT_TAG-servicedesk $PUSH_REPOSITORY
