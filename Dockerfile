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
ENV JIRA_VERSION 6.4.10
ENV CONTEXT_PATH ROOT
ENV JIRA_HOME /opt/atlassian-home
RUN wget --no-check-certificate --directory-prefix=/usr/local/share/atlassian/ \
      https://bitbucket.org/atlassianlabs/atlassian-docker/raw/32fa82ae2516187a783f997c1edc7e56a3f012eb/base/common.bash && \
      /usr/sbin/groupadd jira && \
      echo "%jira ALL=NOPASSWD: /usr/local/bin/own-volume" >> /etc/sudoers && \
      mkdir -p ${JIRA_HOME} && \
      chmod +x /usr/local/share/atlassian/common.bash && \
      curl -Lk http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz -o /root/jira.tar.gz && \
      /usr/sbin/useradd --create-home --home-dir /opt/jira -g jira --shell /bin/bash jira && \
      tar zxf /root/jira.tar.gz --strip=1 -C /opt/jira && \
      rm /root/jira.tar.gz && \
      chown -R jira:jira ${JIRA_HOME} && \
      echo "jira.home = ${JIRA_HOME}" > /opt/jira/atlassian-jira/WEB-INF/classes/jira-application.properties && \
      chown -R jira:jira /opt/jira && \
      mv /opt/jira/conf/server.xml /opt/jira/conf/server-backup.xml && \
      wget --no-check-certificate --directory-prefix=/usr/local/share/atlassian/ \
            https://bitbucket.org/atlassianlabs/atlassian-docker/raw/32fa82ae2516187a783f997c1edc7e56a3f012eb/jira/launch.bash && \
      sed '6d' /usr/local/share/atlassian/launch.bash >> /usr/local/share/atlassian/launch2.bash && \
      sed '47d' /usr/local/share/atlassian/launch2.bash >> /usr/local/share/atlassian/launch.sh && \
      chmod +x /usr/local/share/atlassian/launch.sh && \
      chown -R jira:jira ${JIRA_HOME}

WORKDIR /opt/jira
VOLUME ["/opt/atlassian-home"]
EXPOSE 8080

ADD imagescripts/docker-entrypoint.sh /opt/jira/docker-entrypoint.sh
ENTRYPOINT ["/opt/jira/docker-entrypoint.sh"]
CMD ["jira"]
