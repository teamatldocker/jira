# Dockerized Atlassian Jira

[![Circle CI](https://circleci.com/gh/blacklabelops/jira/tree/master.svg?style=shield)](https://circleci.com/gh/blacklabelops/jira/tree/master) [![Docker Repository on Quay.io](https://quay.io/repository/blacklabelops/jirasoftware/status "Docker Repository on Quay")](https://quay.io/repository/blacklabelops/jirasoftware) [![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/jira.svg)](https://hub.docker.com/r/blacklabelops/jira/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/jira.svg)](https://hub.docker.com/r/blacklabelops/jira/) [![](https://badge.imagelayers.io/blacklabelops/jira:latest.svg)](https://imagelayers.io/?images=blacklabelops/jira:latest 'Get your own badge on imagelayers.io')

## Supported tags and respective Dockerfile links

* `7.0.10`, `latest` [(Dockerfile)](https://github.com/blacklabelops/jira/blob/master/Dockerfile)
* `6.4.12` [(Dockerfile)](https://github.com/blacklabelops/jira/blob/jira6/Dockerfile) [(Readme)](https://github.com/blacklabelops/jira/tree/jira6)

## Instant Usage

[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://stackfiles.io/registry/56b9c12635a28a01009e5811)

## Make It Short

Docker-Compose:

~~~~
$ curl -O https://raw.githubusercontent.com/blacklabelops/jira/master/jirasoftware/docker-compose.yml
$ docker-compose up -d
~~~~

> Jira will be available at http://yourdockerhost

Docker-CLI:

~~~~
$ docker run -d -p 80:8080 --name jira blacklabelops/jira
~~~~

> Jira will be available at http://yourdockerhost

## Database Setup

1. Start a database server.
1. Create a database with the correct collate.
1. Start Jira.

Example with PostgreSQL:

First start the database server:

> Note: Change Password!

~~~~
$ docker run --name postgres -d \
    -e 'POSTGRES_USER=jira' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    postgres:9.5
~~~~

> This is the official postgres image.

Then create the database with the correct collate:

~~~~
$ docker run -it --rm \
    --link postgres:postgres \
    postgres:9.5 \
    sh -c 'exec createdb -E UNICODE -l C -T template0 jiradb -h postgres -p 5432 -U jira'
~~~~

> Creates the database `jiradb` under user `jira` with the correct encoding and collation.

Then start Jira:

~~~~
$ docker run -d --name jira \
	  -e "JIRA_DATABASE_URL=postgresql://jira@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish"  \
	  --link postgres:postgres \
	  -p 80:8080 blacklabelops/jira
~~~~

>  Start the Jira and link it to the postgresql instance.

## Demo Database Setup

> Note: It's not recommended to use a default initialized database for Jira in production! The default databases are all using a not recommended collation! Please use this for demo purposes only!

This is a demo "by foot" using the docker cli. In this example we setup an empty PostgreSQL container. Then we connect and configure the Jira accordingly. Afterwards the Jira container can always resume on the database.

Steps:

* Start Database container
* Start Jira

### PostgreSQL

Let's take an PostgreSQL Docker Image and set it up:

Postgres Official Docker Image:

~~~~
$ docker run --name postgres -d \
    -e 'POSTGRES_DB=jiradb' \
    -e 'POSTGRES_USER=jiradb' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    postgres:9.5
~~~~

> This is the official postgres image.

Postgres Community Docker Image:

~~~~
$ docker run --name postgres -d \
    -e 'DB_USER=jiradb' \
    -e 'DB_PASS=jellyfish' \
    -e 'DB_NAME=jiradb' \
    sameersbn/postgresql:9.4-12
~~~~

> This is the sameersbn/postgresql docker container I tested.

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
	  -e "JIRA_DATABASE_URL=postgresql://jiradb@postgres/jiradb" \
	  -e "JIRA_DB_PASSWORD=jellyfish"  \
	  --link postgres:postgres \
	  -p 80:8080 blacklabelops/jira
~~~~

>  Start the Jira and link it to the postgresql instance.

### MySQL

Let's take an MySQL container and set it up:

MySQL Official Docker Image:

~~~~
$ docker run -d --name mysql \
    -e 'MYSQL_ROOT_PASSWORD=verybigsecretrootpassword' \
    -e 'MYSQL_DATABASE=jiradb' \
    -e 'MYSQL_USER=jiradb' \
    -e 'MYSQL_PASSWORD=jellyfish' \
    mysql:5.6
~~~~

> This is the tutum/mysql docker container I tested.

MySQL Community Docker Image:

~~~~
$ docker run -d --name mysql \
    -e 'ON_CREATE_DB=jiradb' \
    -e 'MYSQL_USER=jiradb' \
    -e 'MYSQL_PASS=jellyfish' \
    tutum/mysql:5.6
~~~~

> This is the tutum/mysql docker container I tested.

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
    -e "JIRA_DATABASE_URL=mysql://jiradb@mysql/jiradb" \
    -e "JIRA_DB_PASSWORD=jellyfish"  \
    --link mysql:mysql \
    -p 80:8080 \
    blacklabelops/jira
~~~~

>  Start the Jira and link it to the postgresql instance.

## Proxy Configuration

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

## NGINX HTTP Proxy

This is an example on running Atlassian Jira behind NGINX with 2 Docker commands!

First start Jira:

~~~~
$ docker run -d --name jira \
    -e "JIRA_PROXY_NAME=192.168.99.100" \
    -e "JIRA_PROXY_PORT=80" \
    -e "JIRA_PROXY_SCHEME=http" \
    blacklabelops/jira
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 80:8080 \
    --name nginx \
    --link jira:jira \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://jira:8080" \
    blacklabelops/nginx
~~~~

> Jira will be available at http://192.168.99.100.

## NGINX HTTPS Proxy

This is an example on running Atlassian Jira behind NGINX-HTTPS with2 Docker commands!

Note: This is a self-signed certificate! Trusted certificates by letsencrypt are supported. Documentation can be found here: [blacklabelops/nginx](https://github.com/blacklabelops/nginx)

First start Jira:

~~~~
$ docker run -d --name jira \
    -e "JIRA_PROXY_NAME=192.168.99.100" \
    -e "JIRA_PROXY_PORT=443" \
    -e "JIRA_PROXY_SCHEME=https" \
    blacklabelops/jira
~~~~

> Example with dockertools

Then start NGINX:

~~~~
$ docker run -d \
    -p 443:44300 \
    --name nginx \
    --link jira:jira \
    -e "SERVER1REVERSE_PROXY_LOCATION1=/" \
    -e "SERVER1REVERSE_PROXY_PASS1=http://jira:8080" \
    -e "SERVER1CERTIFICATE_DNAME=/CN=CrustyClown/OU=SpringfieldEntertainment/O=crusty.springfield.com/L=Springfield/C=US" \
    -e "SERVER1HTTPS_ENABLED=true" \
    -e "SERVER1HTTP_ENABLED=false" \
    blacklabelops/nginx
~~~~

> Confluence will be available at https://192.168.99.100.

## Log File Configuration

You can reconfigure the logfile location with the environment variable JIRA_LOGFILE_LOCATION!

Example:

~~~~
$ docker run -d --name jira \
    -e "JIRA_LOGFILE_LOCATION=/var/atlassian/jira/logs" \
    blacklabelops/jira
~~~~

> Will write logs to /var/atlassian/jira/logs. Note: Must be accessible by jira:jira user!

## Vagrant

First install:

* [Vagrant](https://www.vagrantup.com/)
* [Virtualbox](https://www.virtualbox.org/)

Vagrant is fabulous tool for pulling and spinning up virtual machines like docker with containers. I can configure my development and test environment and simply pull it online. And so can you! Install Vagrant and Virtualbox and spin it up. Change into the project folder and build the project on the spot!

~~~~
$ vagrant up
$ vagrant ssh
[vagrant@localhost ~]$ cd /vagrant
[vagrant@localhost ~]$ docker-compose up
~~~~

> Jira will be available on localhost:8100 on the host machine.

## Support

Leave a message and ask questions on Hipchat: [blacklabelops/hipchat](https://www.hipchat.com/geogBFvEM)

## Credits

This project is very grateful for code and examples from the repository:

[atlassianlabs/atlassian-docker](https://bitbucket.org/atlassianlabs/atlassian-docker)

## References
* [Atlassian Jira](https://www.atlassian.com/software/jira)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Oracle Java](https://java.com/de/download/)
