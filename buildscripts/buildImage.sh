#!/bin/bash -x

set -o errexit    # abort script at first error

function buildImage() {
  local release=$1
  local version=$2
  local tagname=$3
  local dockerfile=$4
  local language=$5
  local country=$6
  docker build --no-cache -t atldocker/jira:$tagname --build-arg JIRA_PRODUCT=$release --build-arg JIRA_VERSION=$version --build-arg LANG_LANGUAGE=$language --build-arg LANG_COUNTRY=$country --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") -f $dockerfile .
}

buildImage $1 $2 $3 $4 $5 $6
