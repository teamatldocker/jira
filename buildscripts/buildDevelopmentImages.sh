#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly BUILD_VERSION=$JIRA_VERSION
readonly BUILD_VERSION_SERVICE_DESK=$JIRA_SERVICE_DESK_VERSION
readonly BUILD_DEVELOPMENT_TAG=$JIRA_DEVELOPMENT_TAG

source $CUR_DIR/buildImage.sh jira-software $BUILD_VERSION $BUILD_DEVELOPMENT_TAG-software Dockerfile en US
source $CUR_DIR/buildImage.sh jira-core $BUILD_VERSION $BUILD_DEVELOPMENT_TAG-core Dockerfile en US
source $CUR_DIR/buildImage.sh servicedesk $BUILD_VERSION_SERVICE_DESK $BUILD_DEVELOPMENT_TAG-servicedesk Dockerfile en US
