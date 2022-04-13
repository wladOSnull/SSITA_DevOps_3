# Geo Citizen

## Commands

Main commands for building and managing Geo Citizen Docker image:

- for **ubuntu** based:

  ```bash
  # build Docker image
  ~ DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build -t geo-supervisor .
  # run dockerized Geo Citizen infrastructure
  ~ docker run -d -p 80:8080 -p 9000:80 -p 9005:5432 -p 9999:9001 geo-supervisor
  # interaction with Geo Citizen container
  ~ docker exec -it ??? bash
  ```

- for **alpine** based:

  ```bash
  # build Docker image; add 'BUILDKIT_PROGRESS=plain' for full logs
  ~ time DOCKER_BUILDKIT=1 docker build -t geo-alpine-supervisor .
  # create volume for PostgreSQL
  ~ docker volume create geovolume
  # run dockerized Geo Citizen infrastructure:
  # - first -p: for Tomcat
  # - second -p: for Supervisor web interface
  ~ docker run -d -p 80:8080 -p 9999:9001 geo-alpine-supervisor
  ~ docker run -d -p 80:8080 -p 9999:9001 --mount source=geovolume,destination=/var/lib/postgresql/data geo-alpine-supervisor
  # interaction with Geo Citizen container
  ~ docker exec -it ??? bash
  ```  

- for Docker volume:

  ```bash
  ~ docker volume create geovolume
  ~ docker volume list
  ~ docker run -it --mount source=test,destination=/var/lib/postgresql/data alpine


apk update
apk add postgresql

mkdir /run/postgresql
chown postgres:postgres /run/postgresql/

chown -R postgres:postgres /var/lib/postgresql/.
??? su -l postgres -c 'initdb -D /var/lib/postgresql/data'

su -l postgres -c 'pg_ctl start -D /var/lib/postgresql/data -l /var/lib/postgresql/log.log'

su -l postgres -c psql
create database test;
CREATE TABLE ...

  ```

Additional commands: 

  ```bash
  # check size of running container 
  ~ docker container ls -s

  # check info about certain image
  ~ docker images geo-alpine-supervisor

  # deply Geo Citizen .war in running container
  ~ docker cp ./citizen.war ???:/opt/tomcat/latest/webapps/citizen.war

  # copy to/from docker container
  ~ docker cp foo.txt container_id:/foo.txt
  ~ docker cp container_id:/foo.txt foo.txt
  
  # PostgreSQL has own CLI with start/stop/restart ... options !
  ~ /etc/init.d/postgresql restart

  # connect to PostgreSQL remotelly
  ~ psql -h 35.226.240.92 -p 9005 -d postgres -U postgres -W

  # exporting Java variable for mvn
  ~ export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.14.1.1-2.el8_5.x86_64
  ```

## Additional

Web interface of Supervisord is configured in */etc/supervisord/supervisord.conf* by '[inet_http_server]' block. Then you can visit the page by http://public-ip-of-vm:port -> http://35.226.240.92:9999/ (in my case)

## Info

Gmail and 3rd-party apps -> [support.google](https://support.google.com/accounts/answer/6010255?hl=en)