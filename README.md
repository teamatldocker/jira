# Dockerized Atlassian Jira

## Introduction
Run Jira Core, Jira Software, or Jira Service Desk in a Docker container.

"The best software teams ship early and often - Not many tools, one tool. Jira Software is built for every member of your software team to plan, track, and release great software." - [[Source](https://www.atlassian.com/software/jira)]

## Products, Versions, and Tags

| Product | Version | Tags |
|---------|---------|-------|
| [Jira Software](https://www.atlassian.com/software/jira) | 8.22.4 | latest, 8.22.4, latest.de, 8.22.4.de |
| [Jira Service Desk](https://www.atlassian.com/software/jira/service-desk) | 4.22.4 | servicedesk, servicedesk.4.22.4, servicedesk.de, servicedesk.4.22.4.de |
| [Jira Core](https://www.atlassian.com/software/jira/core) | 8.22.4 | core, core.8.22.4, core.de, core.8.22.4.de |
> On every release, the oldest and the newest tags are rebuild.

## You may also like

* [teamatldocker/confluence](https://github.com/teamatldocker/confluence): Create, organize, and discuss work with your team
* [teamatldocker/bitbucket](https://github.com/teamatldocker/bitbucket): Code, Manage, Collaborate
* [teamatldocker/crowd](https://github.com/teamatldocker/crowd): Identity management for web apps
* [development - running this image for development including a debugger](https://github.com/teamatldocker/jira/tree/master/examples/debug)

## Setup

### Docker-Compose:
> Jira will be available at http://yourdockerhost

~~~~
$ curl -O https://raw.githubusercontent.com/teamatldocker/jira/master/docker-compose.yml
$ docker-compose up -d
~~~~

### Docker-CLI:
> Jira will be available at http://yourdockerhost
> Data will be persisted inside docker volume `jiravolume`.

~~~~
docker run -d -p 80:8080 -v jiravolume:/var/atlassian/jira --name jira teamatldocker/jira
~~~~

### Docker run

#### 1. Start Database
> This uses the postgres image. Data will be persisted inside docker volume `postgresvolume`.
> Note: You should change the password!
~~~~
docker network create jiranet
docker run --name postgres -d \
    --network jiranet \
    -v postgresvolume:/var/lib/postgresql \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_ENCODING=UNICODE' \
    -e 'POSTGRES_COLLATE=C' \
    -e 'POSTGRES_COLLATE_TYPE=C' \
    postgres:9.5-alpine
~~~~

#### 2. Start Jira
~~~~
docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish"  \
	  -p 80:8080 teamatldocker/jira
~~~~

## Proxy Configuration

You can specify your proxy host and proxy port with the environment variables JIRA_PROXY_NAME and JIRA_PROXY_PORT. The value will be set inside the Atlassian server.xml at startup!

When you use HTTPS then you also have to include the environment variable JIRA_PROXY_SCHEME.

### Example
> This will set the values inside the server.xml in `/opt/jira/conf/server.xml` and build the image with the current Jira release

* Proxy Name: myhost.example.com
* Proxy Port: 443
* Poxy Protocol Scheme: https

~~~~
docker run -d --name jira \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PROXY_NAME=myhost.example.com" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    teamatldocker/jira
~~~~

## Database Setup for Official Database Images

1. Start a database server.
1. Create a database with the correct collate.
1. Start Jira.

Example with PostgreSQL:

First start the database server:

> Note: Change Password!

~~~~
docker network create jiranet
docker run --name postgres -d \
    --network jiranet \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    postgres:9.5
~~~~

> This is the official Postgres image.

Then create the database with the correct collate:

~~~~
docker run -it --rm \
    --network jiranet \
    postgres:9.5-alpine \
    sh -c 'exec createdb -E UNICODE -l C -T template0 jiradb -h postgres -p 5432 -U jira'
~~~~

> Password is `jellyfish`. Creates the database `jiradb` under user `jira` with the correct encoding and collation.

Then start Jira:
>  Start the Jira and link it to the postgres instance.

~~~~
docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish" \
	  -p 80:8080 teamatldocker/jira
~~~~

## Demo Database Setup

> Note: It's not recommended to use a default initialized database for Jira in production! The default databases are all using a not recommended collation! Please use this for demo purposes only!

This is a demo "by foot" using the docker cli. In this example, we setup an empty PostgreSQL container. Then we connect and configure the Jira accordingly. Afterwards, the Jira container can always resume on the database.

Steps:

* Start Database container
* Start Jira

### PostgreSQL

Let's use a PostgreSQL image and set it up:

#### PostgreSQL - official image

~~~~
$ docker network create jiranet
$ docker run --name postgres -d \
    --network jiranet \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_USER=jiradb' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    postgres:9.5-alpine
~~~~

#### PostgreSQL - community image

~~~~
$ docker run --name postgres -d \
    --network jiranet \
    -e 'DB_USER=jiradb' \
    -e 'DB_PASS=jellyfish' \
    -e 'DB_NAME=jiradb' \
    sameersbn/postgresql:9.5-4
~~~~

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  -e "JIRA_DATABASE_URL=postgresql://jiradb@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish" \
	  -p 80:8080 teamatldocker/jira
~~~~

### MySQL

Let's use a MySQL image and set it up:

#### MySQL - official image

~~~~
$ docker network create jiranet
$ docker run -d --name mysql \
    --network jiranet \
    -e 'MYSQL_ROOT_PASSWORD=verybigsecretrootpassword' \
    -e 'MYSQL_DATABASE=jiradb' \
    -e 'MYSQL_USER=jiradb' \
    -e 'MYSQL_PASSWORD=jellyfish' \
    mysql:5.6
~~~~

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_DATABASE_URL=mysql://jiradb@mysql/jiradb" \
    -e "JIRA_DB_PASSWORD=jellyfish"  \
    -p 80:8080 \
    teamatldocker/jira
~~~~

### SQL Server

Starting with version 7.8.0 of Jira, Atlassian no longer provides/uses the jTDS JDBC driver and instead bundles the Microsoft JDBC driver.  This proves to be a bit of a headache because while the jTDS driver used the conventional JDBC URL scheme, Microsoft's driver uses a non-standard JDBC URL scheme that departs wildly from the usual (see [Issue #72](https://github.com/teamatldocker/jira/issues/72) for details).  As a result of this deviation from the standard, users wishing to connect to a SQL Server database *MUST* encode their host/port/database information in the `JIRA_DATABASE_URL` and cannot leverage the individual `JIRA_DB_*` variables. Note that any additional driver properties needed can be appended in much the same was as `databaseName` is handled in the example below.

~~~~
docker run \
    -d \
    --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_DATABASE_URL=sqlserver://MySQLServerHost:1433;databaseName=MyDatabase" \
    -e "JIRA_DB_USER=jira-app" \
    -e "JIRA_DB_PASSWORD=***" \
    -p 8080:8080 \
    teamatldocker/jira
~~~~

## Database Wait Feature

A Jira container can wait for the database container to start up. You have to specify the host and port of your database container and Jira will wait up to one minute for the database.

You can define the waiting parameters with the environment variables:

* `DOCKER_WAIT_HOST`: The host to poll Mandatory!
* `DOCKER_WAIT_PORT`: The port to poll Mandatory!
* `DOCKER_WAIT_TIMEOUT`: The timeout in seconds. Optional! Default: 60
* `DOCKER_WAIT_INTERVAL`: The time in seconds we should wait before polling the database again. Optional! Default: 5

Example waiting for a PostgreSQL database:

First start Jira:

~~~~
docker network create jiranet
docker run --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "DOCKER_WAIT_HOST=postgres" \
    -e "DOCKER_WAIT_PORT=5432" \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish"  \
	  -p 80:8080 teamatldocker/jira
~~~~

> Waits at most 60 seconds for the database.

Start the database within 60 seconds:

~~~~
docker run --name postgres -d \
    --network jiranet \
    -v postgresvolume:/var/lib/postgresql \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_ENCODING=UNICODE' \
    -e 'POSTGRES_COLLATE=C' \
    -e 'POSTGRES_COLLATE_TYPE=C' \
    postgres:9.5-alpine
~~~~

# Build The Image

```
docker-compose build jira
```

If you want to build a specific release, just replace the version in .env and again run

```
docker-compose build jirqa
```

* Proxy Name: myhost.example.com
* Proxy Port: 443
* Poxy Protocol Scheme: https

Just type:

~~~~
$ docker run -d --name jira \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PROXY_NAME=myhost.example.com" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    teamatldocker/jira
~~~~

> Will set the values inside the server.xml in /opt/jira/conf/server.xml

# NGINX HTTP Proxy

This is an example on running Atlassian Jira behind NGINX with 2 Docker commands!

First start Jira:

~~~~
$ docker network create jiranet
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PROXY_NAME=192.168.99.100" \
    -e "JIRA_PROXY_PORT=80" \
    -e "JIRA_PROXY_SCHEME=http" \
    teamatldocker/jira
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 80:80 \
    --network jiranet \
    --name nginx \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://jira:8080" \
    teamatldocker/nginx
~~~~

> Jira will be available at http://192.168.99.100.

# NGINX HTTPS Proxy

This is an example on running Atlassian Jira behind NGINX-HTTPS with2 Docker commands!

Note: This is a self-signed certificate! Trusted certificates by letsencrypt are supported. Documentation can be found here: [teamatldocker/nginx](https://github.com/teamatldocker/nginx)

First start Jira:

~~~~
$ docker network create jiranet
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PROXY_NAME=192.168.99.100" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    teamatldocker/jira
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 443:443 \
    --name nginx \
    --network jiranet \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://jira:8080" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=CrustyClown/OU=SpringfieldEntertainment/O=crusty.springfield.com/L=Springfield/C=US" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    teamatldocker/nginx
~~~~

> Jira will be available at https://192.168.99.100.

## Configuration

### A Word About Memory Usage

Jira like any Java application needs a huge amount of memory. If you limit the memory usage by using the Docker --mem option make sure that you give enough memory. Otherwise, Jira will begin to restart randomly.

You should give at least 1-2GB more than the JVM maximum memory setting to your container.

Java JVM memory settings are applied by manipulating properties inside the `setenv.sh` file and this image can set those properties for you.

The following example applies the [minimum memory for Jira 8.0+](https://confluence.atlassian.com/adminjira/preparing-for-jira-8-0-955171967.html#PreparingforJira8.0-mem) of 2048 megabytes and a maximum of 8192 megabytes.

The correct properties from the Atlassian documentation are:
- `JVM_MINIMUM_MEMORY`
- `JVM_MAXIMUM_MEMORY`

The image will set those properties, if you precede the property name with `SETENV_`.

~~~~
docker run -d -p 80:8080 --name jira \
    -v jiravolume:/var/atlassian/jira \
    -e "SETENV_JVM_MINIMUM_MEMORY=2048m" \
    -e "SETENV_JVM_MAXIMUM_MEMORY=8192m" \
    teamatldocker/jira
~~~~

### Jira Startup Plugin Purge

You can enable osgi plugin purge on startup and restarts. The image will merciless purge the direcories

* /var/atlassian/jira/plugins/.bundled-plugins
* /var/atlassian/jira/plugins/.osgi-plugins

This will help solving [corrupted plugin caches](https://confluence.atlassian.com/jirakb/troubleshooting-jira-startup-failed-error-394464512.html#TroubleshootingJIRAStartupFailedError-Cache). Make sure to [increasing the plugin timeout](https://confluence.atlassian.com/jirakb/troubleshooting-jira-startup-failed-error-394464512.html#TroubleshootingJIRAStartupFailedError-Time) because Jira will have to rebuild the whole cache at each startup.

This is controlled by the environment variable `JIRA_PURGE_PLUGINS_ONSTART`. Possible values:

* `true`: Purge will be done each time container is started or restarted.
* `false` (Default): No purge will be done.

Example:

~~~~
$ docker run -d -p 80:8080 -v jiravolume:/var/atlassian/jira \
    -e "JIRA_PURGE_PLUGINS_ONSTART=true" \
    --name jira teamatldocker/jira
~~~~

# Jira SSO With Crowd

You enable Single Sign On with Atlassian Crowd. What is crowd?

"Users can come from anywhere: Active Directory, LDAP, Crowd itself, or any mix thereof. Control permissions to all your applications in one place – Atlassian, Subversion, Google Apps, or your own apps." - [Atlassian Crowd](https://www.atlassian.com/software/crowd/overview)

This is controlled by the environment variable `JIRA_CROWD_SSO`. Possible values:

* `true`: Jira configuration will be set to Crowd SSO authentication class at every restart.
* `false`: Jira configuration will be set to Jira Authentication class at every restart.
* `ignore` (Default): Config will not be touched, current image setting will be taken.

You have to follow the manual for further settings inside Jira and Crowd: [Documentation](https://confluence.atlassian.com/crowd/integrating-crowd-with-atlassian-jira-192625.html)

Example:

~~~~
$ docker run -d -p 80:8080 -v jiravolume:/var/atlassian/jira \
    -e "JIRA_CROWD_SSO=true" \
    --name jira teamatldocker/jira
~~~~

> SSO will be activated, you will need Crowd in order to authenticate.

## Custom Configuration

You can use your customized configuration, e.g. Tomcat's `server.xml`. This is necessary when you need to configure something inside Tomcat that cannot be achieved by this image's supported environment variables. I will give an example for `server.xml` any other configuration file works analogous.

1. First create your own valid `server.xml`.
1. Mount the file into the proper location inside the image. E.g. `/opt/jira/conf/server.xml`.
1. Start Jira

~~~~
docker run -d --name jira \
    -p 80:8080 \
    -v jiravolume:/var/atlassian/jira \
    -v $(pwd)/server.xml:/opt/jira/conf/server.xml \
    teamatldocker/jira
~~~~

> Note: `server.xml` is located in the directory where the command is executed.

### Extending This Image

You can easily extend this image with your own tooling by following the example below:

~~~~
FROM teamatldocker/jira

USER root

... Install your tooling ...

USER jira
CMD ["jira"]
~~~~

## Upgrading Jira

### Run in debug mode

This description is without any guarantee as this procedure may get outdated or omit critical details which may lead to data loss. Use at own risk.
If you want to run Jira with a debug port, please see `examples/debug` - essentially what we do is
 - we add the debug port as an env parameter
 - we overwrite the start-jira.sh script so we do not user `catalina.sh run` as startup bun rater `catalina.sh jpda run` .. that is about anything we changed in there
 - we expose the port 5005 to the host so we can connect

Before you take any action make sure you can potentially upgrade:

1. Check inside Jira administration panel if your installed plugins are all upwards compatible. Jira has a very good feedback system where you can see if you plugin provider is compatible to the latest Jira version.

2. Check or ask inside this repository if anyone has tested the latest image. I have experienced issues when Jira has upgraded to a new major version: E.g. 6.x to 7.x. In this case sometimes the image has to be adapted. Minor versions and especially bugfix version can be usually be used without any problems.

Now make a `Backup` in order to be able to fallback:

1. Stop your database and Jira instance.
2. Make a backup of your volumes. (Both Jira and database). For example use (https://github.com/blacklabelops/volumerize)[blacklabelops/volumerize] to backup your volume.

Now `Upgrade` your Jira container:

1. Remove your stopped Jira container: `docker rm your_jira_container_name`
2. Upgrade your local image: `docker pull teamatldocker/jira:new_version`
3. Use the same start command as the last container but with the new image `teamatldocker/jira:new_version`
4. Jira will start its upgrading routine on both the local files and database. Run `docker logs -f your_jira_container_name` and lookout for error messages.

Now `Test` your Jira instance:

1. Login and check your functionality
2. Check if all plugins are running
3. Check Jira administration pannel for error messages

Test okay?

Your finished!

Test not okay?

Rollback:

1. Stop Jira and database instance.
2. Play back your backup. E.g. delete volumes, create volumes and copy back old files. Both Jira and database! You can simplify things with blacklabelops/volumerize.
3.  Remove your stopped Jira container: `docker rm your_jira_container_name`
4. Use the same start command as the last container but with the old image `teamatldocker/jira:old_version`

## Example

Let's assume your running Jira 7.6.2 with my example setup and you want to upgrade to Jira 7.7.1.

PostgreSQL has been started with the following settings:

~~~~
$ docker run --name postgres -d \
    --network jiranet \
    -v postgresvolume:/var/lib/postgresql \
    ...
    postgres:9.5-alpine
~~~~

Jira has been started with the following settings:

~~~~
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  ...
	  -p 80:8080 teamatldocker/jira:7.6.2
~~~~

This means:

* Jira instance has name `jira` and data is inside volume `jiravolume` and has version `7.6.2`.
* Database instance has name `postgres` and data is inside volume `postgresvolume`.

Stop both instance with the following commands:

~~~~
$ docker stop jira
$ docker stop postgres
~~~~

> Correct order is first Jira then database.

`Backup` both volumes in order to be able to `Rollback`. In this example we use [blacklabelops/volumerize](https://github.com/blacklabelops/volumerize) to backup to another volume.

Run the following command to backup both database and Jira in one simple step:

~~~~
$ docker run \
    --rm \
    -v jiravolume:/source/application_data:ro \
    -v postgresvolume:/source/application_database_data:ro \
    -v jirabackup:/backup \
    -e "VOLUMERIZE_SOURCE=/source" \
    -e "VOLUMERIZE_TARGET=file:///backup" \
    blacklabelops/volumerize backup
~~~~

> `jiravolume` and `postgresvolume` will have a backup inside jirabackup.

Now `Upgrade` Jira by switching the container to a new image:

~~~~
$ docker rm jira
$ docker pull teamatldocker/jira:7.7.1
~~~~

Start the database and Jira with the same parameters as before but with the new image tag `7.7.1`:

~~~~
$ docker start postgres
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  ...
	  -p 80:8080 teamatldocker/jira:7.7.1
~~~~

Wait until Jira has ended the upgrade procedure and your instance is available again!

1. Login and check your functionality
2. Check if all plugins are running
3. Check the Jira administration panel for error messages

If everything looks good, you're finished!

If you encountered an issue, you can `Rollback` to the last version.

Stop both instance with the following commands:

~~~~
docker stop jira
docker stop postgres
~~~~

`Restore` both volumes in order to be able to use the last version again. In this example we use [blacklabelops/volumerize](https://github.com/blacklabelops/volumerize) to restore from another volume.

Run the following command to restore both database and Jira in one simple step:

~~~~
$ docker run \
    --rm \
    -v jiravolume:/source/application_data \
    -v postgresvolume:/source/application_database_data \
    -v jirabackup:/backup:ro \
    -e "VOLUMERIZE_SOURCE=/source" \
    -e "VOLUMERIZE_TARGET=file:///backup" \
    blacklabelops/volumerize restore
~~~~

> Data will be written back to `jiravolume` and `postgresvolume`.

Start the old version again:

Start the database and Jira with the same parameters as before but with the old image `7.6.2`:

~~~~
$ docker start postgres
$ docker rm jira
$ docker run -d --name jira \
    --network jiranet \
    -v jiravolume:/var/atlassian/jira \
	  ...
	  -p 80:8080 teamatldocker/jira:7.6.2
~~~~
