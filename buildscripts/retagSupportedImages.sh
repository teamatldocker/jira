#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly RETAG_REPOSITORY=$1
readonly PUSH_VERSION=$JIRA_VERSION
readonly PUSH_SERVICE_DESK_VERSION=$JIRA_SERVICE_DESK_VERSION

function retagImage() {
  local tagname=$1
  local repository=$2
  docker tag teamatldocker/jira:$tagname $repository/jira:$tagname
}

retagImage latest $RETAG_REPOSITORY
retagImage $PUSH_VERSION $RETAG_REPOSITORY
retagImage latest.de $RETAG_REPOSITORY
retagImage $PUSH_VERSION.de $RETAG_REPOSITORY
retagImage core $RETAG_REPOSITORY
retagImage core.$PUSH_VERSION $RETAG_REPOSITORY
retagImage core.de $RETAG_REPOSITORY
retagImage core.$PUSH_VERSION.de $RETAG_REPOSITORY
retagImage servicedesk $RETAG_REPOSITORY
retagImage servicedesk.$PUSH_SERVICE_DESK_VERSION $RETAG_REPOSITORY
retagImage servicedesk.de $RETAG_REPOSITORY
retagImage servicedesk.$PUSH_SERVICE_DESK_VERSION.de $RETAG_REPOSITORY
