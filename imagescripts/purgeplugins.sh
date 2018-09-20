#!/bin/bash
#
# A cleaning script.
#
# Purges Jira plugin cache.
#

set -o errexit

[[ ${DEBUG} == true ]] && set -x

if [ -d "${JIRA_HOME}/plugins/.bundled-plugins" ]; then
  rm -rf ${JIRA_HOME}/plugins/.bundled-plugins
fi

if [ -d "${JIRA_HOME}/plugins/.osgi-plugins" ]; then
  rm -rf ${JIRA_HOME}/plugins/.osgi-plugins
fi
