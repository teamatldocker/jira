#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly PUSH_REPOSITORY=$1
readonly PUSH_VERSION=$JIRA_VERSION
readonly PUSH_SERVICE_DESK_VERSION=$JIRA_SERVICE_DESK_VERSION

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

pushImage latest $PUSH_REPOSITORY
pushImage $PUSH_VERSION $PUSH_REPOSITORY
pushImage latest.de $PUSH_REPOSITORY
pushImage $PUSH_VERSION.de $PUSH_REPOSITORY
pushImage core $PUSH_REPOSITORY
pushImage core.$PUSH_VERSION $PUSH_REPOSITORY
pushImage core.de $PUSH_REPOSITORY
pushImage core.$PUSH_VERSION.de $PUSH_REPOSITORY
pushImage servicedesk $PUSH_REPOSITORY
pushImage servicedesk.$PUSH_SERVICE_DESK_VERSION $PUSH_REPOSITORY
pushImage servicedesk.de $PUSH_REPOSITORY
pushImage servicedesk.$PUSH_SERVICE_DESK_VERSION.de $PUSH_REPOSITORY
