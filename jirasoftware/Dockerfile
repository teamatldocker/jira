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
    wget --no-check-certificate --directory-prefix=${JIRA_SCRIPTS} \
      https://bitbucket.org/atlassianlabs/atlassian-docker/raw/32fa82ae2516187a783f997c1edc7e56a3f012eb/base/common.bash && \
    chmod +x ${JIRA_SCRIPTS}/common.bash && \
    mkdir -p ${JIRA_HOME} && \
    mkdir -p ${JIRA_INSTALL} && \
    wget --no-check-certificate -O /tmp/jira.bin https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-${JIRA_VERSION}-jira-${JIRA_VERSION}-x64.bin && \
    chmod +x /tmp/jira.bin && \
    /tmp/jira.bin -q -varfile ${JIRA_SCRIPTS}/response.varfile && \
    curl -Ls "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.38.tar.gz" | tar -xz --directory "${JIRA_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-5.1.38/mysql-connector-java-5.1.38-bin.jar" && \
    mv ${JIRA_INSTALL}/lib/mysql-connector-java-5.1.38-bin.jar ${JIRA_INSTALL}/lib/mysql-connector-java-5.1.30-bin.jar && \
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
