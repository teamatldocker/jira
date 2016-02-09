FROM blacklabelops/java-jre-8:alpine
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

ENV JIRA_VERSION=7.0.10                       \
    JIRA_USER=jira                            \
    JIRA_GROUP=jira                           \
    JIRA_CONTEXT_PATH=ROOT                    \
    JIRA_HOME=/var/atlassian/jira             \
    JIRA_INSTALL=/opt/jira                    \
    JIRA_SCRIPTS=/usr/local/share/atlassian

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
