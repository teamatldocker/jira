#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly TEST_VERSION=$JIRA_VERSION
readonly TEST_SERVICE_DESK_VERSION=$JIRA_SERVICE_DESK_VERSION
readonly BUILD_DEVELOPMENT_TAG=$JIRA_DEVELOPMENT_TAG

docker network create jira_dockertestnet

source $CUR_DIR/testImage.sh $BUILD_DEVELOPMENT_TAG-software 8220
source $CUR_DIR/testImage.sh $BUILD_DEVELOPMENT_TAG-core 8260
source $CUR_DIR/testImage.sh $BUILD_DEVELOPMENT_TAG-servicedesk 8300
