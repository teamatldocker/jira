# Dockerized Atlassian Jira

[![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/jira.svg)](https://hub.docker.com/r/blacklabelops/jira/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/jira.svg)](https://hub.docker.com/r/blacklabelops/jira/)

"The best software teams ship early and often - Not many tools, one tool. JIRA Software is built for every member of your software team to plan, track, and release great software." - [[Source](https://www.atlassian.com/software/jira)]

## Supported tags and respective Dockerfile links

| Product |Version | Tags  | Dockerfile |
|---------|--------|-------|------------|
| Jira Software | 7.3.6 | 7.3.6, latest, latest.de | [Dockerfile](https://github.com/blacklabelops/jira/blob/master/Dockerfile) |
| Jira Service Desk | 3.5.0 | servicedesk, servicedesk.3.5.0, servicedesk.de, servicedesk.3.5.0.de | [Dockerfile](https://github.com/blacklabelops/jira/blob/master/Dockerfile) |
| Jira Core | 7.3.6 | core, core.7.3.6, core.de, core.7.3.6.de | [Dockerfile](https://github.com/blacklabelops/jira/blob/master/Dockerfile) |

> Older tags remain but are not supported/rebuild.

> `.de` postfix means images are installed with preset language german locale.

## Related Images

You may also like:

* [blacklabelops/jira](https://github.com/blacklabelops/jira): The #1 software development tool used by agile teams
* [blacklabelops/confluence](https://github.com/blacklabelops/confluence): Create, organize, and discuss work with your team
* [blacklabelops/bitbucket](https://github.com/blacklabelops/bitbucket): Code, Manage, Collaborate
* [blacklabelops/crowd](https://github.com/blacklabelops/crowd): Identity management for web apps

# Make It Short

Docker-Compose:

~~~~
$ curl -O https://raw.githubusercontent.com/blacklabelops/jira/master/docker-compose.yml
$ docker-compose up -d
~~~~

> Jira will be available at http://yourdockerhost

Docker-CLI:

~~~~
$ docker run -d -p 80:8080 --name jira blacklabelops/jira
~~~~

> Jira will be available at http://yourdockerhost

# Setup

1. Start database server.
1. Start Jira.

First start the database server:

> Note: Change Password!

~~~~
$ docker network create jiranet
$ docker run --name postgres -d \
    --network jiranet \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_ENCODING=UNICODE' \
    -e 'POSTGRES_COLLATE=C' \
    -e 'POSTGRES_COLLATE_TYPE=C' \
    blacklabelops/postgres
~~~~

> This is the blacklabelops postgres image.

Then start Jira:

~~~~
$ docker run -d --name jira \
    --network jiranet \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish"  \
	  -p 80:8080 blacklabelops/jira
~~~~

>  Start the Jira and link it to the postgresql instance.

# Database Setup for Official Database Images

1. Start a database server.
1. Create a database with the correct collate.
1. Start Jira.

Example with PostgreSQL:

First start the database server:

> Note: Change Password!

~~~~
$ docker network create jiranet
$ docker run --name postgres -d \
    --network jiranet \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    postgres:9.4
~~~~

> This is the official postgres image.

Then create the database with the correct collate:

~~~~
$ docker run -it --rm \
    --network jiranet \
    postgres:9.4 \
    sh -c 'exec createdb -E UNICODE -l C -T template0 jiradb -h postgres -p 5432 -U jira'
~~~~

> Password is `jellyfish`. Creates the database `jiradb` under user `jira` with the correct encoding and collation.

Then start Jira:

~~~~
$ docker run -d --name jira \
    --network jiranet \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish" \
	  -p 80:8080 blacklabelops/jira
~~~~

>  Start the Jira and link it to the postgresql instance.

# Demo Database Setup

> Note: It's not recommended to use a default initialized database for Jira in production! The default databases are all using a not recommended collation! Please use this for demo purposes only!

This is a demo "by foot" using the docker cli. In this example we setup an empty PostgreSQL container. Then we connect and configure the Jira accordingly. Afterwards the Jira container can always resume on the database.

Steps:

* Start Database container
* Start Jira

## PostgreSQL

Let's take an PostgreSQL Docker Image and set it up:

Postgres Official Docker Image:

~~~~
$ docker network create jiranet
$ docker run --name postgres -d \
    --network jiranet \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_USER=jiradb' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    postgres:9.4
~~~~

> This is the official postgres image.

Postgres Community Docker Image:

~~~~
$ docker run --name postgres -d \
    --network jiranet \
    -e 'DB_USER=jiradb' \
    -e 'DB_PASS=jellyfish' \
    -e 'DB_NAME=jiradb' \
    sameersbn/postgresql:9.4-12
~~~~

> This is the sameersbn/postgresql docker container I tested.

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
    --network jiranet \
	  -e "JIRA_DATABASE_URL=postgresql://jiradb@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish" \
	  -p 80:8080 blacklabelops/jira
~~~~

>  Start the Jira and link it to the postgresql instance.

## MySQL

Let's take an MySQL container and set it up:

MySQL Official Docker Image:

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

> This is the mysql docker container I tested.

MySQL Community Docker Image:

~~~~
$ docker run -d --name mysql \
    --network jiranet \
    -e 'ON_CREATE_DB=jiradb' \
    -e 'MYSQL_USER=jiradb' \
    -e 'MYSQL_PASS=jellyfish' \
    tutum/mysql:5.6
~~~~

> This is the tutum/mysql docker container I tested.

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
    --network jiranet \
    -e "JIRA_DATABASE_URL=mysql://jiradb@mysql/jiradb" \
    -e "JIRA_DB_PASSWORD=jellyfish"  \
    -p 80:8080 \
    blacklabelops/jira
~~~~

>  Start the Jira and link it to the mysql instance.

# Proxy Configuration

You can specify your proxy host and proxy port with the environment variables JIRA_PROXY_NAME and JIRA_PROXY_PORT. The value will be set inside the Atlassian server.xml at startup!

When you use https then you also have to include the environment variable JIRA_PROXY_SCHEME.

Example HTTPS:

* Proxy Name: myhost.example.com
* Proxy Port: 443
* Poxy Protocol Scheme: https

Just type:

~~~~
$ docker run -d --name jira \
    -e "JIRA_PROXY_NAME=myhost.example.com" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    blacklabelops/jira
~~~~

> Will set the values inside the server.xml in /opt/jira/conf/server.xml

# NGINX HTTP Proxy

This is an example on running Atlassian Jira behind NGINX with 2 Docker commands!

First start Jira:

~~~~
$ docker network create jiranet
$ docker run -d --name jira \
    --network jiranet \
    -e "JIRA_PROXY_NAME=192.168.99.100" \
    -e "JIRA_PROXY_PORT=80" \
    -e "JIRA_PROXY_SCHEME=http" \
    blacklabelops/jira
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
    blacklabelops/nginx
~~~~

> Jira will be available at http://192.168.99.100.

# NGINX HTTPS Proxy

This is an example on running Atlassian Jira behind NGINX-HTTPS with2 Docker commands!

Note: This is a self-signed certificate! Trusted certificates by letsencrypt are supported. Documentation can be found here: [blacklabelops/nginx](https://github.com/blacklabelops/nginx)

First start Jira:

~~~~
$ docker network create jiranet
$ docker run -d --name jira \
    --network jiranet \
    -e "JIRA_PROXY_NAME=192.168.99.100" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    blacklabelops/jira
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
    blacklabelops/nginx
~~~~

> Jira will be available at https://192.168.99.100.

# Support & Feature Requests

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](http://support.blacklabelops.com)

# Credits

This project is very grateful for code and examples from the repository:

[atlassianlabs/atlassian-docker](https://bitbucket.org/atlassianlabs/atlassian-docker)

# References

* [Atlassian Jira](https://www.atlassian.com/software/jira)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Oracle Java](https://java.com/de/download/)
