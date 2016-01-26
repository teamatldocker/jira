FROM blacklabelops/java-jre-8
MAINTAINER Steffen Bleul <sbl@blacklabelops.com>

ENV JIRA_VERSION=7.0.9 \
    JIRA_USER=jira \
    JIRA_GROUP=jira \
    JIRA_CONTEXT_PATH=ROOT \
    JIRA_HOME=/var/atlassian/jira \
    JIRA_INSTALL=/opt/jira \
    JIRA_SCRIPTS=/usr/local/share/atlassian

COPY imagescripts ${JIRA_SCRIPTS}

RUN yum install -y epel-release && \
    yum install -y \
    xmlstarlet \
    wget && \
    yum clean all && rm -rf /var/cache/yum/* && \
    # Install Jira
    mkdir -p ${JIRA_HOME} && \
    mkdir -p ${JIRA_INSTALL} && \
    wget --no-check-certificate -O /tmp/jira.bin https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-${JIRA_VERSION}-jira-${JIRA_VERSION}-x64.bin && \
    chmod +x /tmp/jira.bin && \
    /tmp/jira.bin -q -varfile ${JIRA_SCRIPTS}/response.varfile && \
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_HOME} && \
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_INSTALL} && \
    chown -R $JIRA_USER:$JIRA_GROUP ${JIRA_SCRIPTS} && \
    rm -rf /tmp/*

USER jira
WORKDIR /opt/jiradata
VOLUME ["/opt/jiradata"]
EXPOSE 8080
ENTRYPOINT ["/usr/local/share/atlassian/docker-entrypoint.sh"]
CMD ["jira"]
