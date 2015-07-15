FROM blacklabelops/centos
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

# install java
ENV JAVA_VERSION=1.7.0_76
ENV JAVA_TARBALL=jre-7u76-linux-x64.tar.gz
ENV JAVA_HOME=/opt/java/jre${JAVA_VERSION}
RUN wget --no-check-certificate --directory-prefix=/tmp \
         --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
         http://download.oracle.com/otn-pub/java/jdk/7u76-b13/${JAVA_TARBALL} && \
    mkdir -p /opt/java && \
    tar -xzf /tmp/${JAVA_TARBALL} -C /opt/java/ && \
    alternatives --install /usr/bin/java java /opt/java/jre${JAVA_VERSION}/bin/java 100 && \
    rm -rf /tmp/* && rm -rf /var/log/*

# install jira
ENV JIRA_VERSION 6.4.7
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
      chmod +x /usr/local/share/atlassian/launch.sh

WORKDIR /opt/jira
VOLUME ["/opt/atlassian-home"]
EXPOSE 8080

ADD imagescripts/docker-entrypoint.sh /opt/jira/docker-entrypoint.sh
ENTRYPOINT ["/opt/jira/docker-entrypoint.sh"]
CMD ["jira"]
