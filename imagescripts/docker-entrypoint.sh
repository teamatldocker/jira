#!/bin/bash -x
set -o errexit

chown -R jira:jira /opt/atlassian-home

if [ "$1" = 'jira' ]; then
  cat /usr/local/share/atlassian/launch.sh

  /bin/bash -x /usr/local/share/atlassian/launch.sh

  runuser -l jira -c '/opt/jira/bin/start-jira.sh -fg'
fi

exec "$@"
