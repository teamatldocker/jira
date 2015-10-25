FROM blacklabelops/java-jre-7
MAINTAINER Steffen Bleul <blacklabelops@itbleul.de>

# install dev tools
RUN yum install -y epel-release && \
    yum install -y \
    tar \
    curl \
    sudo \
    xmlstarlet \
    wget \
    zip && \
    yum clean all && rm -rf /var/cache/yum/*

# install jira
ENV JIRA_VERSION 7.0.0
ENV CONTEXT_PATH ROOT
ENV JIRA_HOME /opt/jiradata
ADD imagescripts/response.varfile /tmp/response.varfile
ADD imagescripts/launch.sh /usr/local/share/atlassian/launch.sh
RUN wget --no-check-certificate --directory-prefix=/usr/local/share/atlassian/ \
      https://bitbucket.org/atlassianlabs/atlassian-docker/raw/32fa82ae2516187a783f997c1edc7e56a3f012eb/base/common.bash && \
      /usr/sbin/groupadd jira && \
      echo "%jira ALL=NOPASSWD: /usr/local/bin/own-volume" >> /etc/sudoers && \
      mkdir -p ${JIRA_HOME} && \
      chmod +x /usr/local/share/atlassian/common.bash && \
      wget --no-check-certificate -O /tmp/jira.bin https://downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-${JIRA_VERSION}-jira-${JIRA_VERSION}-x64.bin && \
      chmod +x /tmp/jira.bin && \
      /tmp/jira.bin -q -varfile /tmp/response.varfile && \
      rm -rf /tmp/* && \
      /usr/sbin/useradd --create-home --home-dir /opt/jira -g jira --shell /bin/bash jira && \
      chown -R jira:jira ${JIRA_HOME} && \
      echo "jira.home = ${JIRA_HOME}" > /opt/jira/atlassian-jira/WEB-INF/classes/jira-application.properties && \
      chown -R jira:jira /opt/jira && \
      mv /opt/jira/conf/server.xml /opt/jira/conf/server-backup.xml && \
      chown -R jira:jira ${JIRA_HOME}

WORKDIR /opt/jira
VOLUME ["/opt/jiradata"]
EXPOSE 8080
EXPOSE 8005

ADD imagescripts/docker-entrypoint.sh /root/docker-entrypoint.sh
ENTRYPOINT ["/root/docker-entrypoint.sh"]
CMD ["jira"]
