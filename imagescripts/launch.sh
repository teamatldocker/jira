#!/bin/bash

set -o errexit

. ${JIRA_SCRIPTS}/common.sh

rm -f /opt/atlassian-home/.jira-home.lock

if [ "$JIRA_CONTEXT_PATH" == "ROOT" -o -z "$JIRA_CONTEXT_PATH" ]; then
  CONTEXT_PATH=
else
  CONTEXT_PATH="/$JIRA_CONTEXT_PATH"
fi

xmlstarlet ed -P -S -L -u '//Context/@path' -v "$CONTEXT_PATH" ${JIRA_INSTALL}/conf/server.xml

if [ -n "$JIRA_DATABASE_URL" ]; then
  extract_database_url "$JIRA_DATABASE_URL" JIRA_DB ${JIRA_INSTALL}/lib
  JIRA_DB_JDBC_URL="$(xmlstarlet esc "$JIRA_DB_JDBC_URL")"
  SCHEMA=''
  if [ "$JIRA_DB_TYPE" != "mysql" ]; then
    SCHEMA='<schema-name>public</schema-name>'
  fi

  cat <<END > ${JIRA_HOME}/dbconfig.xml
<?xml version="1.0" encoding="UTF-8"?>
<jira-database-config>
  <name>defaultDS</name>
  <delegator-name>default</delegator-name>
  <database-type>$JIRA_DB_TYPE</database-type>
  $SCHEMA
  <jdbc-datasource>
    <url>$JIRA_DB_JDBC_URL</url>
    <driver-class>$JIRA_DB_JDBC_DRIVER</driver-class>
    <username>$JIRA_DB_USER</username>
    <password>$JIRA_DB_PASSWORD</password>
    <pool-min-size>20</pool-min-size>
    <pool-max-size>20</pool-max-size>
    <pool-max-wait>30000</pool-max-wait>
    <pool-max-idle>20</pool-max-idle>
    <pool-remove-abandoned>true</pool-remove-abandoned>
    <pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>
    <validation-query>select version();</validation-query>
    <validation-query-timeout>3</validation-query-timeout>
    <min-evictable-idle-time-millis>60000</min-evictable-idle-time-millis>
    <time-between-eviction-runs-millis>300000</time-between-eviction-runs-millis>
    <pool-test-on-borrow>false</pool-test-on-borrow>
    <pool-test-while-idle>true</pool-test-while-idle>
  </jdbc-datasource>
</jira-database-config>
END
fi
