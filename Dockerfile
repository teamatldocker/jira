FROM blacklabelops/alpine:3.5
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

# Note that you also need to update buildscripts/release.sh when the
# Jira version changes
ARG JIRA_VERSION=7.4.0
ARG JIRA_PRODUCT=jira-software
# Permissions, set the linux user id and group id
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000
# Image Build Date By Buildsystem
ARG BUILD_DATE=undefined
# Language Settings
ARG LANG_LANGUAGE=en
ARG LANG_COUNTRY=US

ENV JIRA_USER=jira                            \
    JIRA_GROUP=jira                           \
    JIRA_CONTEXT_PATH=ROOT                    \
    JIRA_HOME=/var/atlassian/jira             \
    JIRA_INSTALL=/opt/jira                    \
    JIRA_SCRIPTS=/usr/local/share/atlassian   \
    MYSQL_DRIVER_VERSION=5.1.38               \
    DOCKERIZE_VERSION=v0.4.0                  \
    POSTGRESQL_DRIVER_VERSION=9.4.1212
ENV JAVA_HOME=$JIRA_INSTALL/jre

ENV PATH=$PATH:$JAVA_HOME/bin \
    LANG=${LANG_LANGUAGE}_${LANG_COUNTRY}.UTF-8

COPY imagescripts ${JIRA_SCRIPTS}

RUN apk add --update                                    \
      ca-certificates                                   \
      gzip                                              \
      curl                                              \
      tini                                              \
      wget                                              \
      xmlstarlet                                    &&  \
    # Install latest glibc
    export GLIBC_VERSION=2.25-r0 && \
    wget --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/glibc-${GLIBC_VERSION}.apk && \
    wget --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    apk add --allow-untrusted /tmp/glibc-bin-${GLIBC_VERSION}.apk && \
    wget --directory-prefix=/tmp https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk && \
    apk --allow-untrusted add /tmp/glibc-i18n-${GLIBC_VERSION}.apk && \
    /usr/glibc-compat/bin/localedef -i ${LANG_LANGUAGE}_${LANG_COUNTRY} -f UTF-8 ${LANG_LANGUAGE}_${LANG_COUNTRY}.UTF-8 && \
    # Install Jira
    export JIRA_BIN=atlassian-${JIRA_PRODUCT}-${JIRA_VERSION}-x64.bin && \
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
      --directory=/tmp                                                                                        &&  \
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
    export KEYSTORE=$JAVA_HOME/lib/security/cacerts && \
    wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx1.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx2.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx1 -file /tmp/letsencryptauthorityx1.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx2 -file /tmp/letsencryptauthorityx2.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx1 -file /tmp/lets-encrypt-x1-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx2 -file /tmp/lets-encrypt-x2-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx3 -file /tmp/lets-encrypt-x3-cross-signed.der && \
    keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx4 -file /tmp/lets-encrypt-x4-cross-signed.der && \
    # Install atlassian ssl tool
    wget -O /home/${JIRA_USER}/SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class && \
    # Set permissions
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_HOME}    &&  \
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_INSTALL} &&  \
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_SCRIPTS} &&  \
    chown -R $JIRA_USER:$JIRA_GROUP /home/${JIRA_USER} &&  \
    # Install dockerize
    wget -O /tmp/dockerize.tar.gz https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf /tmp/dockerize.tar.gz && \
    rm /tmp/dockerize.tar.gz && \
    # Remove obsolete packages
    apk del                                             \
      ca-certificates                                   \
      gzip                                              \
      wget                                          &&  \
    # Clean caches and tmps
    rm -rf /var/cache/apk/*                         &&  \
    rm -rf /tmp/*                                   &&  \
    rm -rf /var/log/*

# Image Metadata
LABEL com.blacklabelops.application.jira.version=$JIRA_PRODUCT-$JIRA_VERSION \
      com.blacklabelops.application.jira.userid=$CONTAINER_UID \
      com.blacklabelops.application.jira.groupid=$CONTAINER_GID \
      com.blacklabelops.image.builddate.jira=${BUILD_DATE}

USER jira
WORKDIR ${JIRA_HOME}
VOLUME ["/var/atlassian/jira"]
EXPOSE 8080
ENTRYPOINT ["/sbin/tini","--","/usr/local/share/atlassian/docker-entrypoint.sh"]
CMD ["jira"]
