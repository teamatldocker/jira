#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly TEST_JENKINS_VERSION=$JIRA_VERSION
readonly TEST_JIRA_STABLE_VERSION=$JIRA_SERVICE_DESK_VERSION

source $CUR_DIR/cleanContainer.sh jira.latest
source $CUR_DIR/cleanContainer.sh jira.$JIRA_VERSION
source $CUR_DIR/cleanContainer.sh jira.latest.de
source $CUR_DIR/cleanContainer.sh jira.$JIRA_VERSION.de
source $CUR_DIR/cleanContainer.sh jira.core
source $CUR_DIR/cleanContainer.sh jira.core.$JIRA_VERSION
source $CUR_DIR/cleanContainer.sh jira.core.de
source $CUR_DIR/cleanContainer.sh jira.core.$JIRA_VERSION.de
source $CUR_DIR/cleanContainer.sh jira.servicedesk
source $CUR_DIR/cleanContainer.sh jira.servicedesk.$JIRA_SERVICE_DESK_VERSION
source $CUR_DIR/cleanContainer.sh jira.servicedesk.de
source $CUR_DIR/cleanContainer.sh jira.servicedesk.$JIRA_SERVICE_DESK_VERSION.de
