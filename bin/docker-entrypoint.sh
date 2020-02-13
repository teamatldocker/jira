#!/bin/bash
#
# A helper script for ENTRYPOINT.
#
# If first CMD argument is 'jira', then the script will start jira
# If CMD argument is overriden and not 'jira', then the user wants to run
# his own process.

set -o errexit

[[ ${DEBUG} == true ]] && set -x

#
# This function purges osgi plugins when env is true
#
function purgeJiraPlugins() {
  if [ "$JIRA_PURGE_PLUGINS_ONSTART" = 'true' ]; then
    bash /usr/local/share/atlassian/purgeplugins.sh
  fi
}

#
# This function will replace variables inside the script setenv.sh
#
function updateSetEnv() {
  local propertyname=$1
  local propertyvalue=$2
  sed -i -e "/${propertyname}=/c${propertyname}=\"${propertyvalue}\"" ${JIRA_INSTALL}/bin/setenv.sh
}

function setAllSetEnvs() {
  local env_vars=$(env | awk -F= '/^SETENV/ {print $1}')
  for env_variable in $env_vars
  do
    local propertyName=${env_variable#"SETENV_"}
    updateSetEnv "$propertyName" "${!env_variable}"
  done
}

#
# This function will wait for a specific host and port for as long as the timeout is specified.
#
function waitForDB() {
  local waitHost=${DOCKER_WAIT_HOST:-}
  local waitPort=${DOCKER_WAIT_PORT:-}
  local waitTimeout=${DOCKER_WAIT_TIMEOUT:-60}
  local waitIntervalTime=${DOCKER_WAIT_INTERVAL:-5}
  if [ -n "${waitHost}" ] && [ -n "${waitPort}" ]; then
    dockerize -timeout "${waitTimeout}"s -wait-retry-interval "${waitIntervalTime}"s -wait tcp://"${waitHost}":"${waitPort}"
  fi
}

SERAPH_CONFIG_FILE="/opt/jira/atlassian-jira/WEB-INF/classes/seraph-config.xml"

#
# Enable crowd sso authenticator java class in image config file
#
function enableCrowdSSO() {
  xmlstarlet ed -P -S -L --delete "//authenticator" $SERAPH_CONFIG_FILE
  xmlstarlet ed -P -S -L -s "//security-config" --type elem -n authenticator -i "//authenticator[not(@class)]" -t attr -n class -v "com.atlassian.jira.security.login.SSOSeraphAuthenticator" $SERAPH_CONFIG_FILE
}

#
# Enable jira authenticator java class in image config file
#
function enableJiraAuth() {
  xmlstarlet ed -P -S -L --delete "//authenticator" $SERAPH_CONFIG_FILE
  xmlstarlet ed -P -S -L -s "//security-config" --type elem -n authenticator -i "//authenticator[not(@class)]" -t attr -n class -v "com.atlassian.jira.security.login.JiraSeraphAuthenticator" $SERAPH_CONFIG_FILE
}

#
# Will either enable, disable Crowd SSO support or ignore current setting at all
#
function controlCrowdSSO() {
  local setting=$1
  case "$setting" in
    true)
      enableCrowdSSO
    ;;
    false)
      enableJiraAuth
    ;;
    *)
      echo "Crowd SSO settings ingored because of setting ${setting}"
    esac
}

if [ -n "${JIRA_DELAYED_START}" ]; then
  sleep "${JIRA_DELAYED_START}"
fi

if [ -n "${JIRA_ENV_FILE}" ]; then
  source "${JIRA_ENV_FILE}"
fi

if [ -n "${JIRA_PROXY_NAME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyName)]" --type attr -n proxyName --value "${JIRA_PROXY_NAME}" ${JIRA_INSTALL}/conf/server.xml
fi

if [ -n "${JIRA_PROXY_PORT}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@proxyPort)]" --type attr -n proxyPort --value "${JIRA_PROXY_PORT}" ${JIRA_INSTALL}/conf/server.xml
fi

if [ -n "${JIRA_PROXY_SCHEME}" ]; then
  xmlstarlet ed -P -S -L --insert "//Connector[not(@scheme)]" --type attr -n scheme --value "${JIRA_PROXY_SCHEME}" ${JIRA_INSTALL}/conf/server.xml
fi

jira_logfile="${JIRA_HOME}/log"

if [ -n "${JIRA_LOGFILE_LOCATION}" ]; then
  jira_logfile=${JIRA_LOGFILE_LOCATION}
fi

if [ -n "${JIRA_CROWD_SSO}" ]; then
  controlCrowdSSO "${JIRA_CROWD_SSO}"
fi

if [ ! -d "${jira_logfile}" ]; then
  mkdir -p "${jira_logfile}"
fi

TARGET_PROPERTY=1catalina.org.apache.juli.AsyncFileHandler.directory
sed -i "/${TARGET_PROPERTY}/d" ${JIRA_INSTALL}/conf/logging.properties
echo "${TARGET_PROPERTY} = ${jira_logfile}" >> ${JIRA_INSTALL}/conf/logging.properties

TARGET_PROPERTY=2localhost.org.apache.juli.AsyncFileHandler.directory
sed -i "/${TARGET_PROPERTY}/d" ${JIRA_INSTALL}/conf/logging.properties
echo "${TARGET_PROPERTY} = ${jira_logfile}" >> ${JIRA_INSTALL}/conf/logging.properties

TARGET_PROPERTY=3manager.org.apache.juli.AsyncFileHandler.directory
sed -i "/${TARGET_PROPERTY}/d" ${JIRA_INSTALL}/conf/logging.properties
echo "${TARGET_PROPERTY} = ${jira_logfile}" >> ${JIRA_INSTALL}/conf/logging.properties

TARGET_PROPERTY=4host-manager.org.apache.juli.AsyncFileHandler.directory
sed -i "/${TARGET_PROPERTY}/d" ${JIRA_INSTALL}/conf/logging.properties
echo "${TARGET_PROPERTY} = ${jira_logfile}" >> ${JIRA_INSTALL}/conf/logging.properties

setAllSetEnvs

if [ "$1" = 'jira' ] || [ "${1:0:1}" = '-' ]; then
  waitForDB
  purgeJiraPlugins
  /bin/bash "${JIRA_SCRIPTS}"/launch.sh
  if [ -n "${JIRA_PROXY_PATH}" ]; then
    xmlstarlet ed -P -S -L --update "//Context/@path" --value "${JIRA_PROXY_PATH}" ${JIRA_INSTALL}/conf/server.xml
  fi
  exec ${JIRA_INSTALL}/bin/start-jira.sh -fg "$@"
else
  exec "$@"
fi
