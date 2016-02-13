FROM blacklabelops/java:jre8
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

ENV JIRA_VERSION=7.1.0                        \
    JIRA_USER=jira                            \
    JIRA_GROUP=jira                           \
    JIRA_CONTEXT_PATH=ROOT                    \
    JIRA_HOME=/var/atlassian/jira             \
    JIRA_INSTALL=/opt/jira                    \
    JIRA_SCRIPTS=/usr/local/share/atlassian   \
    MYSQL_DRIVER_VERSION=5.1.38               \
    POSTGRESQL_DRIVER_VERSION=9.4.1207

COPY imagescripts ${JIRA_SCRIPTS}

RUN apk add --update                                    \
      ca-certificates                                   \
      gzip                                              \
      wget                                          &&  \
    apk add xmlstarlet --update-cache                   \
      --repository                                      \
      http://dl-3.alpinelinux.org/alpine/edge/testing/  \
      --allow-untrusted                             &&  \
    # Install Jira
    export JIRA_BIN=atlassian-jira-software-${JIRA_VERSION}-jira-${JIRA_VERSION}-x64.bin && \
    mkdir -p ${JIRA_HOME}                           &&  \
    mkdir -p ${JIRA_INSTALL}                        &&  \
    wget -O /tmp/jira.bin https://downloads.atlassian.com/software/jira/downloads/${JIRA_BIN} && \
    chmod +x /tmp/jira.bin                          &&  \
    /tmp/jira.bin -q -varfile                           \
      ${JIRA_SCRIPTS}/response.varfile              &&  \
    # Install database drivers
    rm -f                                               \
      ${JIRA_INSTALL}/lib/mysql-connector-java*.jar &&  \
    wget -O /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz                                              \
      http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz      &&  \
    tar xzf /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz                                              \
      mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar           \
      -C /tmp                                                                                                 &&  \
    cp /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar     \
      ${JIRA_INSTALL}/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}-bin.jar                                &&  \
    rm -f ${JIRA_INSTALL}/lib/postgresql-*.jar                                                                &&  \
    wget -O ${JIRA_INSTALL}/lib/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar                                       \
      https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar                        &&  \
    # Add user
    export CONTAINER_USER=jira                      &&  \
    export CONTAINER_UID=1000                       &&  \
    export CONTAINER_GROUP=jira                     &&  \
    export CONTAINER_GID=1000                       &&  \
    addgroup -g $CONTAINER_GID $CONTAINER_GROUP     &&  \
    adduser -u $CONTAINER_UID                           \
            -G $CONTAINER_GROUP                         \
            -h /home/$CONTAINER_USER                    \
            -s /bin/bash                                \
            -S $CONTAINER_USER                      &&  \
    # Set permissions
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_HOME}    &&  \
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_INSTALL} &&  \
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_SCRIPTS} &&  \
    # Remove obsolete packages
    apk del                                             \
      ca-certificates                                   \
      gzip                                              \
      wget                                          &&  \
    # Clean caches and tmps
    rm -rf /var/cache/apk/*                         &&  \
    rm -rf /tmp/*                                   &&  \
    rm -rf /var/log/*

USER jira
WORKDIR ${JIRA_HOME}
VOLUME ["/var/atlassian/jira"]
EXPOSE 8080
ENTRYPOINT ["/usr/local/share/atlassian/docker-entrypoint.sh"]
CMD ["jira"]
