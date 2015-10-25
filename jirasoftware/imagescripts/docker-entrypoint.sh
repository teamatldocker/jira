#!/bin/bash -x
set -o errexit

if [ "$1" = 'jira' ]; then
  cat /usr/local/share/atlassian/launch.sh

  /bin/bash -x /usr/local/share/atlassian/launch.sh

  runuser -l jira -c '/opt/jira/bin/start-jira.sh -fg'
fi

exec "$@"
