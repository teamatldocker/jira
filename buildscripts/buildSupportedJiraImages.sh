#!/bin/bash -x

set -o errexit    # abort script at first error

# Setting environment variables
readonly CUR_DIR=$(cd $(dirname ${BASH_SOURCE:-$0}); pwd)

printf '%b\n' ":: Reading release config...."
source $CUR_DIR/release.sh

readonly BUILD_VERSION=$JIRA_VERSION
readonly BUILD_VERSION_SERVICE_DESK=$JIRA_SERVICE_DESK_VERSION

source $CUR_DIR/buildImage.sh jira-software $BUILD_VERSION latest Dockerfile en US
source $CUR_DIR/buildImage.sh jira-software $BUILD_VERSION $BUILD_VERSION Dockerfile en US
source $CUR_DIR/buildImage.sh jira-software $BUILD_VERSION latest.de Dockerfile de DE
source $CUR_DIR/buildImage.sh jira-software $BUILD_VERSION $BUILD_VERSION.de Dockerfile de DE
source $CUR_DIR/buildImage.sh jira-core $BUILD_VERSION core Dockerfile en US
source $CUR_DIR/buildImage.sh jira-core $BUILD_VERSION core.$BUILD_VERSION Dockerfile en US
source $CUR_DIR/buildImage.sh jira-core $BUILD_VERSION core.de Dockerfile de DE
source $CUR_DIR/buildImage.sh jira-core $BUILD_VERSION core.$BUILD_VERSION.de Dockerfile de DE
source $CUR_DIR/buildImage.sh servicedesk $BUILD_VERSION_SERVICE_DESK servicedesk Dockerfile en US
source $CUR_DIR/buildImage.sh servicedesk $BUILD_VERSION_SERVICE_DESK servicedesk.$BUILD_VERSION_SERVICE_DESK Dockerfile en US
source $CUR_DIR/buildImage.sh servicedesk $BUILD_VERSION_SERVICE_DESK servicedesk.de Dockerfile de DE
source $CUR_DIR/buildImage.sh servicedesk $BUILD_VERSION_SERVICE_DESK servicedesk.$BUILD_VERSION_SERVICE_DESK.de Dockerfile de DE
