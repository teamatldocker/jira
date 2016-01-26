# Dockerized Atlassian Jira Software

> Release: blacklabelops/jirasoftware:latest

[![Circle CI](https://circleci.com/gh/blacklabelops/jira/tree/master.svg?style=shield)](https://circleci.com/gh/blacklabelops/centos/tree/master) [![Docker Repository on Quay.io](https://quay.io/repository/blacklabelops/jirasoftware/status "Docker Repository on Quay")](https://quay.io/repository/blacklabelops/centos) [![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/jirasoftware.svg)](https://hub.docker.com/r/blacklabelops/jirasoftware/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/jirasoftware.svg)](https://hub.docker.com/r/blacklabelops/jirasoftware/)

## Instant Usage

[![Deploy to Tutum](https://s.tutum.co/deploy-to-tutum.svg)](https://dashboard.tutum.co/stack/deploy/)

## Make It Short

Docker-Compose:

~~~~
$ curl -O https://raw.githubusercontent.com/blacklabelops/jira/master/jirasoftware/docker-compose.yml
$ docker-compose up -d
~~~~

> Jira will be available at http://yourdockerhost

Docker-CLI:

~~~~
$ docker run -d -p 80:8080 --name jira blacklabelops/jirasoftware
~~~~

> Jira will be available at http://yourdockerhost

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

## Setup Example Using Docker

This example is "by foot" using the docker cli. In this example we setup an empty PostgreSQL container. Then we connect and configure the Jira accordingly. Afterwards the Jira container can always resume on the database.

### PostgreSQL

Let's take an PostgreSQL Docker Image and set it up:


Postgres Official Docker Image:

~~~~
$ docker run --name postgres -d \
    -e 'POSTGRES_USER=jiradb' \
    -e 'POSTGRES_PASSWORD=jellyfish' \
    -e 'POSTGRES_DB=jiradb' \
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
	  -p 80:8080 blacklabelops/jirasoftware
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
    blacklabelops/jirasoftware
~~~~

>  Start the Jira and link it to the postgresql instance.

## Credits

This project is very grateful for code and examples from the repository:

[atlassianlabs/atlassian-docker](https://bitbucket.org/atlassianlabs/atlassian-docker)

## References

* [Atlassian Jira](https://www.atlassian.com/software/jira)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/
* [Oracle Java8](https://java.com/de/download/)
* [Imagelayers.io](https://imagelayers.io/?images=blacklabelops/jirasoftware:latest)
