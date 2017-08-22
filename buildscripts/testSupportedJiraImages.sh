#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly TEST_VERSION=$JIRA_VERSION
readonly TEST_SERVICE_DESK_VERSION=$JIRA_SERVICE_DESK_VERSION

docker network create jira_dockertestnet

source $CUR_DIR/testImage.sh latest 8220
source $CUR_DIR/testImage.sh $TEST_VERSION 8230
source $CUR_DIR/testImage.sh latest.de 8240
source $CUR_DIR/testImage.sh $TEST_VERSION.de 8250
source $CUR_DIR/testImage.sh core 8260
source $CUR_DIR/testImage.sh core.$TEST_VERSION 8270
source $CUR_DIR/testImage.sh core.de 8280
source $CUR_DIR/testImage.sh core.$TEST_VERSION.de 8290
source $CUR_DIR/testImage.sh servicedesk 8300
source $CUR_DIR/testImage.sh servicedesk.$TEST_SERVICE_DESK_VERSION 8310
source $CUR_DIR/testImage.sh servicedesk.de 8320
source $CUR_DIR/testImage.sh servicedesk.$TEST_SERVICE_DESK_VERSION.de 8330
