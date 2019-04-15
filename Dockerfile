FROM adoptopenjdk/openjdk8-openj9:alpine-jre
# image contains glibc

ARG JIRA_PRODUCT=jira-software
ARG JIRA_VERSION=8.1.0

# Image build date set by build system
ARG BUILD_DATE=undefined

# Language Settings
ARG LANG_LANGUAGE=en
ARG LANG_COUNTRY=US

ENV JIRA_USER=jira                              \
    JIRA_GROUP=jira                             \
    CONTAINER_UID=1000                          \
    CONTAINER_GID=1000                          \
    JIRA_CONTEXT_PATH=ROOT                      \
    JIRA_HOME=/var/atlassian/jira               \
    JIRA_INSTALL=/opt/jira                      \
    JIRA_SCRIPTS=/usr/local/share/atlassian     \
    LANG=${LANG_LANGUAGE}_${LANG_COUNTRY}.UTF-8 \
    JRE_HOME=$JAVA_HOME                         \
    # Fix for this issue - https://jira.atlassian.com/browse/JRASERVER-46152 \
    _RUNJAVA=java

COPY bin $JIRA_SCRIPTS

WORKDIR /tmp

# Install latest bin and i18n; main lib and pub key already installed by parent image
RUN export GLIBC_VERSION=2.29-r0                        \
    && export GLIBC_DOWNLOAD_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION \
    && export GLIBC_BIN=glibc-bin-$GLIBC_VERSION.apk    \
    && export GLIBC_I18N=glibc-i18n-$GLIBC_VERSION.apk  \
    && wget $GLIBC_DOWNLOAD_URL/$GLIBC_BIN              \
    && wget $GLIBC_DOWNLOAD_URL/$GLIBC_I18N             \
    && yes | apk add --update --no-cache                \
                 bash                                   \
                 su-exec                                \
                 gzip                                   \
                 nano                                   \
                 tini                                   \
                 wget                                   \
                 # editing conf files                   \
                 xmlstarlet                             \
                 # gliblc language                      \
                 $GLIBC_BIN                             \
                 $GLIBC_I18N                            \
                 # fonts                                \
                 fontconfig                             \
                 msttcorefonts-installer                \
                 ttf-dejavu                             \
                 ghostscript                            \
                 graphviz                               \
                 motif                                  \
    && update-ms-fonts \
    && fc-cache -f     \
    && /usr/glibc-compat/bin/localedef -i ${LANG_LANGUAGE}_${LANG_COUNTRY} -f UTF-8 $LANG \
    # JAVA_TOOL_OPTIONS, JAVA_HOME, and PATH already get set by AdoptOpenJDK image \
    # Since installer uses Oracle JDK 8, it does not recognize 'IgnoreUnrecognizedVMOptions' in JAVA_TOOL_OPTIONS \
    && export JAVA_TOOL_OPTIONS="" \
    #&& export JAVA_HOME=$JIRA_INSTALL/jre \
    #&& export PATH=$PATH:$JAVA_HOME/bin \
    # Run installer and setup user/group \
    && mkdir -p $JIRA_HOME $JIRA_INSTALL                           \
    && wget -O jira.bin https://www.atlassian.com/software/jira/downloads/binary/atlassian-$JIRA_PRODUCT-$JIRA_VERSION-x64.bin \
    && chmod +x jira.bin                                       \
    && ./jira.bin -q -varfile $JIRA_SCRIPTS/response.varfile   \
    && addgroup -g $CONTAINER_GID $JIRA_GROUP                  \
    && adduser -u $CONTAINER_UID                               \
        -G $JIRA_GROUP                                         \
        -h /home/$JIRA_USER                                    \
        -s /bin/bash                                           \
        -S $JIRA_USER                                          \
    # remove installer JRE and link to AdoptOpenJDK            \
    && rm -rf $JIRA_INSTALL/jre                                \
    && ln -s $JAVA_HOME $JIRA_INSTALL/jre                      \
    # Install database drivers                                 \
    && export JIRA_LIB=$JIRA_INSTALL/lib                       \
    && export MYSQL_DRIVER_VERSION=5.1.47                      \
    && export MYSQL_FILE_BASE=mysql-connector-java-$MYSQL_DRIVER_VERSION \
    && export MYSQL_FILE_TAR=$MYSQL_FILE_BASE.tar.gz           \
    && export MYSQL_FILE_BIN=$MYSQL_FILE_BASE-bin.jar          \
    && export MYSQL_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/Connector-J/$MYSQL_FILE_TAR \
    && export POSTGRESQL_DRIVER_VERSION=42.2.5                 \
    && export POSTGRESQL_FILE=postgresql-$POSTGRESQL_DRIVER_VERSION.jar \
    && export POSTGRESQL_DOWNLOAD_URL=https://jdbc.postgresql.org/download/$POSTGRESQL_FILE \
    && rm -f $JIRA_LIB/mysql-connector-java*.jar               \
    && wget -O $MYSQL_FILE_TAR $MYSQL_DOWNLOAD_URL             \
    && tar xzf $MYSQL_FILE_TAR --strip=1                       \
    && cp $MYSQL_FILE_BIN $JIRA_LIB/$MYSQL_FILE_BIN            \
    && rm -f $JIRA_LIB/postgresql-*.jar                        \
    && wget -O $JIRA_LIB/$POSTGRESQL_FILE $POSTGRESQL_DOWNLOAD_URL \
    # Dockerize                                                \
    && export DOCKERIZE_VERSION=v0.6.1                         \
    && export DOCKERIZE_DOWNLOAD_URL=https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    # Let's Encrypt \
    && export LE_DOWNLOAD_URL=https://letsencrypt.org/certs/   \
    && export LE_AUTH_1=letsencryptauthorityx1.der             \
    && export LE_AUTH_2=letsencryptauthorityx2.der             \
    && export LE_CROSS_1=lets-encrypt-x1-cross-signed.der      \
    && export LE_CROSS_2=lets-encrypt-x2-cross-signed.der      \
    && export LE_CROSS_3=lets-encrypt-x3-cross-signed.der      \
    && export LE_CROSS_4=lets-encrypt-x4-cross-signed.der      \
    # Adding Let's Encrypt CA to truststore                    \
    && export KEYSTORE=$JRE_HOME/lib/security/cacerts          \
    && wget $LE_DOWNLOAD_URL/$LE_AUTH_1                        \
    && wget $LE_DOWNLOAD_URL/$LE_AUTH_2                        \
    && wget $LE_DOWNLOAD_URL/$LE_CROSS_1                       \
    && wget $LE_DOWNLOAD_URL/$LE_CROSS_2                       \
    && wget $LE_DOWNLOAD_URL/$LE_CROSS_3                       \
    && wget $LE_DOWNLOAD_URL/$LE_CROSS_4                       \
    && keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx1 -file $LE_AUTH_1              \
    && keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx2 -file $LE_AUTH_2              \
    && keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx1 -file $LE_CROSS_1 \
    && keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx2 -file $LE_CROSS_2 \
    && keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx3 -file $LE_CROSS_3 \
    && keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx4 -file $LE_CROSS_4 \
    # Install Atlassian SSL tool - mainly to be able to create application links with other Atlassian tools, which run LE SSL certificates \
    && wget -O /home/$JIRA_USER/SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class  \
    # Set permissions                                                                          \
    && chown -R $JIRA_USER:$JIRA_GROUP $JIRA_HOME $JIRA_INSTALL $JIRA_SCRIPTS /home/$JIRA_USER \
    # Install Dockerize                                                                        \
    && wget -O dockerize.tar.gz $DOCKERIZE_DOWNLOAD_URL                                        \
    && tar -C /usr/local/bin -xzvf dockerize.tar.gz                                            \
    && rm dockerize.tar.gz                                                                     \
    # Remove build packages                                                                    \
    && apk del                                                                                 \
      --no-cache                                                                               \
      gzip                                                                                     \
      msttcorefonts-installer                                                                  \
      wget                                                                                     \
    # Clean caches and tmps                                                                    \
    && rm -rf /var/cache/apk/* /tmp/* /var/log/*

# Image Metadata
LABEL maintainer="Jonathan Hult <atldocker@JonathanHult.com>"                                  \
    org.opencontainers.image.authors="Jonathan Hult <atldocker@JonathanHult.com>"              \
    org.opencontainers.image.title=$JIRA_PRODUCT                                               \
    org.opencontainers.image.description="$JIRA_PRODUCT $JIRA_VERSION running on Alpine Linux" \
    org.opencontainers.image.source="https://github.com/atldocker/jira/"                       \
    org.opencontainers.image.created=$BUILD_DATE                                               \
    org.opencontainers.image.version=$JIRA_VERSION

USER $JIRA_USER
WORKDIR $JIRA_HOME
VOLUME ["$JIRA_HOME"]
EXPOSE 8080
ENTRYPOINT ["/sbin/tini","--","/usr/local/share/atlassian/docker-entrypoint.sh"]
CMD ["jira"]
