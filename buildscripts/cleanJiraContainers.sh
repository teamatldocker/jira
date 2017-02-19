#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly TEST_JENKINS_VERSION=$JIRA_VERSION
readonly TEST_JIRA_STABLE_VERSION=$JIRA_SERVICE_DESK_VERSION

source $CUR_DIR/cleanContainer.sh latest
source $CUR_DIR/cleanContainer.sh $JIRA_VERSION
source $CUR_DIR/cleanContainer.sh latest.de
source $CUR_DIR/cleanContainer.sh $JIRA_VERSION.de
source $CUR_DIR/cleanContainer.sh core
source $CUR_DIR/cleanContainer.sh core.$JIRA_VERSION
source $CUR_DIR/cleanContainer.sh core.de
source $CUR_DIR/cleanContainer.sh core.$JIRA_VERSION.de
source $CUR_DIR/cleanContainer.sh servicedesk
source $CUR_DIR/cleanContainer.sh servicedesk.$JIRA_SERVICE_DESK_VERSION
source $CUR_DIR/cleanContainer.sh servicedesk.de
source $CUR_DIR/cleanContainer.sh servicedesk.$JIRA_SERVICE_DESK_VERSION.de
