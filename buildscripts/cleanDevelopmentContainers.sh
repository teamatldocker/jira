#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly TEST_JENKINS_VERSION=$JIRA_VERSION
readonly TEST_JIRA_STABLE_VERSION=$JIRA_SERVICE_DESK_VERSION
readonly BUILD_DEVELOPMENT_TAG=$JIRA_DEVELOPMENT_TAG

source $CUR_DIR/cleanContainer.sh jira.$BUILD_DEVELOPMENT_TAG-software
source $CUR_DIR/cleanContainer.sh jira.$BUILD_DEVELOPMENT_TAG-core
source $CUR_DIR/cleanContainer.sh jira.$BUILD_DEVELOPMENT_TAG-servicedesk
