# Dockerized Atlassian Jira 6

[![Circle CI](https://circleci.com/gh/blacklabelops/jira/tree/master.svg?style=shield)](https://circleci.com/gh/blacklabelops/centos/tree/master) [![Docker Stars](https://img.shields.io/docker/stars/blacklabelops/jira.svg)](https://hub.docker.com/r/blacklabelops/jira/) [![Docker Pulls](https://img.shields.io/docker/pulls/blacklabelops/jira.svg)](https://hub.docker.com/r/blacklabelops/jira/)

## Release: blacklabelops/jira:latest

Looking for Jira Software or Jira7? Can be found here: [blacklabelops/jirasoftware](https://github.com/blacklabelops/jira/tree/master/jirasoftware/README.md)

## Make It Short

~~~~
docker run -d -p 80:8080 --name="jira_jira_1" blacklabelops/jira
~~~~

> This will pull the container and start Atlassian Jira on http://yourhost.

## Features

Container has the following features:

* Install and startup Jira on the fly.
* Set the Jira version number.
* Container writes data to Docker volume.
* Scripts for backup of Jira data.
* Scripts for restore of Jira data.
* Supports the Docker-Compose tool.
* Includes several convenient cli wrapper scripts around docker.

## What's Included

* Atlassian Jira 6
* CentOS 7
* Java 7

## Works with

* Docker latest
* Docker-Compose latest

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

> Jira will be available on http://localhost:8100

## Usage

This container includes all the required scripts for container management. Simply clone the project and enter the described commands in your project directory.

### Project Usage

This project can be used from the command line, by bash scripts and the Docker-Compose tool. It's recommended to use the scripts for container management.

#### Run Recommended

~~~~
$ ./scripts/run.sh
~~~~

> This will run the container with the configuration scripts/container.cfg

#### Run Docker-Compose

~~~~
$ docker-compose -d up
~~~~

> This will run the container detached with the configuration docker-composite.yml

#### Run Command Line

~~~~
$ docker run -d -p 8100:8080 --name="jira_jira_1" blacklabelops/jira
~~~~

> This will run the jenkins on default settings and port 8100

#### Build Recommended

~~~~
$ ./scripts/build.sh
~~~~

> This will build the container from scratch with all required parameters.

#### Build Docker-Compose

~~~~
docker-compose -f docker-compose-dev.yml build
~~~~

> This will build the container according to the docker-compose-dev.yml file.

#### Build Docker Command Line

~~~~
docker build -t="blacklabelops/jira" .
~~~~

> This will build the container from scratch.

## Setting the Jira Database

This container can be run with an existent MySQL or PostegreSQL database. The database is configurable with a jdbc URL:

~~~~
postgresql://jiradb@192.168.59.103/jiradb
~~~~

> PostgreSQL database with 'jiradb' as user, running the database on host with ip '192.168.59.103' and database name 'jiradb'.

The URL must be of the following form:

~~~~
DATABASE_TYPE://DATABASE_USER@DATABASE_HOST/DATABASE_NAME
~~~~

> * DATABASE_TYPE = postgresql or mysql
> * DATABASE_USER = Any preconfigured Jira database user.
> * DATABASE_HOST = Network adress of the host's database.
> * DATABASE_NAME = Any preconfigured Jira database.

#### PostgreSQL

Now your ready sping up jira with postgres with docker-compose.

~~~~
$ docker-compose -f docker-compose-postgres.yml up
~~~~

And if you want to start the example detached add '-d'

~~~~
$ docker-compose -f docker-compose-postgres.yml up -d
~~~~

#### MySQL

Now your ready sping up jira with postgres with docker-compose.

~~~~
$ docker-compose -f docker-compose-mysql.yml up
~~~~

And if you want to start the example detached add '-d'

~~~~
$ docker-compose -f docker-compose-mysql.yml up -d
~~~~

### Example using Docker

This example is "by foot" using the docker cli. In this example we setup an empty PostgreSQL container. Then we connect and configure the Jira accordingly. Afterwards the Jira container can always resume on the database.

#### PostgreSQL

Let's take an PostgreSQL container and set it up:

~~~~
$ docker run --name postgresql -d \
  -e 'PSQL_TRUST_LOCALNET=true' \
  -e 'DB_USER=jiradb' \
  -e 'DB_PASS=jellyfish' \
  -e 'DB_NAME=jiradb' \
  -p 5432:5432 \
  sameersbn/postgresql:9.4-1
~~~~

> This is the sameersbn/postgresql docker container I tested. This container now can be used with the following jdbc URL: postgresql://jiradb@postgresql/jiradb (I link the container with hostname postgresql)

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
	-e "DATABASE_URL=postgresql://jiradb@postgresql/jiradb" \
	-e "DB_PASSWORD=jellyfish"  \
	--link postgresql:postgresql \
	-p 8100:8080 blacklabelops/jira
~~~~

>  Start the Jira and link it to the postgresql instance.

#### MySQL

Let's take an MySQL container and set it up:

~~~~
$ docker run -d --name mysql \
  -e 'ON_CREATE_DB=jiradb' \
  -e 'MYSQL_USER=jiradb' \
  -e 'MYSQL_PASS=jellyfish' \
  -p 3306:3306 \
  tutum/mysql:5.6
~~~~

> This is the tutum/mysql docker container I tested. This container now can be used with the following jdbc URL: mysql://jiradb@mysql/jiradb (I use link with hostname mysql)

Now start the Jira container and let it use the container. On first startup you have to configure your Jira yourself and fill it with a test license. Afterwards every time you connect to a database the Jira configuration will be skipped.

~~~~
$ docker run -d --name jira \
	-e "DATABASE_URL=mysql://jiradb@mysql/jiradb" \
	-e "DB_PASSWORD=jellyfish"  \
	--link mysql:mysql \
	-p 8100:8080 \
	blacklabelops/jira
~~~~

>  Start the Jira and link it to the postgresql instance.


## Docker Wrapper Scripts

Convenient wrapper scripts for container and image management. The scripts manage one container. In oder to manage multiple containers, copy the scripts and adjust the container.cfg.

Name              | Description
----------------- | ------------
build.sh          | Build the container from scratch.
run.sh            | Run the container.
start.sh          | Start the container from a stopped state.
stop.sh           | Stop the container from a running state.
rm.sh             | Kill all running containers and remove it.
rmi.sh            | Delete container image.
mng.sh            | Manage the docker volume from another container.

> Simply invoke the commands in the project's folder.

## Feature Scripts

Feature scripts for the container. The scripts manage one container. In oder to manage multiple containers, copy the scripts and adjust the container.cfg.

Name              | Description
----------------- | ------------
logs.sh  | Downloads a Jira logs file from container
backup.sh         | Backups docker volume ["/opt/atlassian-home"] from container
restore.sh        | Restore the backup into Jira container

> The examples are executed from project folder.

### logs.sh

This script will search for configured docker container. If no container
found, an error message will be shown. Otherwise, an jenkins logs will be
copied by default into 'logs' folder with following file name and timestamp.

~~~~
$ ./scripts/logs.sh
~~~~

> The log file with timestamp as name und suffix ".log" can be found in the project's logs folder.

### backup.sh

Backup of docker volume in a tar archive.

~~~~
$ ./scripts/backup.sh
~~~~

> The backups will be placed in the project's backups folder.

### restore.sh

Restore container from a tar archive.

~~~~
$ ./scripts/restore.sh ./backups/JiraBackup-2015-03-08-16-28-40.tar
~~~~

> A temp container will be created and backup file will be extracted into docker volume. The container will be stopped and restartet afterwards.

## Managing Multiple Containers

The scripts can be configured for the support of different containers on the same host manchine. Just copy and paste the project and folder and adjust the configuration file scripts/container.cfg

Name              | Description
----------------- | ------------
CONTAINER_NAME    | The name of the docker container.
IMAGE_NAME         | The name of the docker image.
HOST_PORT        | The exposed port on the host machine.
BACKUP_DIRECTORY | Change the backup directory.
LOGFILE_DIRECTORY | Change the logs download directory.
FILE_TIMESTAMP | Timestamp format for logs and backups.

> Note: CONTAINER_VOLUME must not be changed.

## Setting the Jira Version

The Jira version is configured inside the Dockerfile. Please consider that backups will only work with the respective Jira version.

Dockerfile:

~~~~
ENV JIRA_VERSION 6.4.7
~~~~

> This will install the Jira version 6.4.7. The respective URL is quite stable so this will work in future releases.

## Docker-Compose

This project supports docker-compose. The configuration is inside the docker-compose.yml file.

Example:

~~~~
$ docker-compose up -d
~~~~

> Starts a detached docker container.

Consult the [docker-compose](https://docs.docker.com/compose/) manual for specifics.

## Credits

This project is very grateful for code and examples from the repository:

[atlassianlabs/atlassian-docker](https://bitbucket.org/atlassianlabs/atlassian-docker)

## References

* [Atlassian Jira](https://www.atlassian.com/software/jira)
* [Docker Homepage](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Docker Userguide](https://docs.docker.com/userguide/)
* [Oracle Java8](https://java.com/de/download/)
* [Imagelayers.io](https://imagelayers.io/?images=blacklabelops/jira:latest)
