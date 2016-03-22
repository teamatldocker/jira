FROM blacklabelops/alpine:3.3
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

ENV JIRA_CORE_VERSION=7.1.2                   \
    JIRA_USER=jira                            \
    JIRA_GROUP=jira                           \
    JIRA_CONTEXT_PATH=ROOT                    \
    JIRA_HOME=/var/atlassian/jira             \
    JIRA_INSTALL=/opt/jira                    \
    JIRA_SCRIPTS=/usr/local/share/atlassian   \
    MYSQL_DRIVER_VERSION=5.1.38               \
    POSTGRESQL_DRIVER_VERSION=9.4.1207
ENV JAVA_HOME=$JIRA_INSTALL/jre
ENV PATH=$PATH:$JAVA_HOME/bin

COPY imagescripts ${JIRA_SCRIPTS}

RUN apk add --update                                    \
      ca-certificates                                   \
      gzip                                              \
      wget                                          &&  \
    apk add xmlstarlet --update-cache                   \
      --repository                                      \
      http://dl-3.alpinelinux.org/alpine/edge/testing/  \
      --allow-untrusted                             &&  \
    # Install latest glibc
    export GLIBC_VERSION=2.22-r8 && \
    wget --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/glibc-${GLIBC_VERSION}.apk && \
    wget --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/glibc-bin-${GLIBC_VERSION}.apk && \
    wget --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
    apk --allow-untrusted add /tmp/glibc-i18n-${GLIBC_VERSION}.apk && \
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 && \
    # Install Jira
    export JIRA_BIN=atlassian-jira-core-${JIRA_CORE_VERSION}-x64.bin && \
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
    # Adding letsencrypt-ca to truststore
    wget -O /home/${JIRA_USER}/letsencrypt-int.crt https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.pem.txt && \
    keytool -import -alias letsencrypt-int -keystore /opt/jira/jre/lib/security/cacerts -storepass changeit -noprompt -importcert -file /home/${JIRA_USER}/letsencrypt-int.crt && \
    rm -f /home/${JIRA_USER}/letsencrypt-int.crt && \
    # Install atlassian ssl tool
    wget -O /home/${JIRA_USER}/SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/SSLPoke.class && \
    # Set permissions
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_HOME}    &&  \
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_INSTALL} &&  \
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_SCRIPTS} &&  \
    chown -R $JIRA_USER:$JIRA_GROUP /home/${JIRA_USER} &&  \
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
