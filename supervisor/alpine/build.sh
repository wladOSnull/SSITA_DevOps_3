#!/bin/sh

############################################################
#
# This is a bash script for configuring independent 
# Geo Citizen Docker image based on Alpine Linux 
# for Tomcat+PostgreSQL infrastructure
#
############################################################

### common
apk update

### configure PostgreSQL
apk add --no-cache postgresql
mkdir /run/postgresql
chown postgres:postgres /run/postgresql/
su -l postgres -c 'initdb -D /var/lib/postgresql/data'

sed -i "s/#password_encryption = scram-sha-256/password_encryption = md5/g" /var/lib/postgresql/data/postgresql.conf
su -l postgres -c 'pg_ctl start -D /var/lib/postgresql/data -l /var/lib/postgresql/log.log'

### configure DB for Geo Citizen
su -l postgres -c "psql -c \"ALTER USER postgres PASSWORD 'postgres';\""
su -l postgres -c "psql -c \"CREATE USER geocitizen WITH PASSWORD 'weakpass';\""
su -l postgres -c "psql -c \"ALTER USER geocitizen CREATEDB;\""
su -l postgres -c "psql -c \"CREATE DATABASE ss_demo_1;\""
su -l postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE ss_demo_1 to geocitizen;\""

### configure PostgreSQL for external access
rm /var/lib/postgresql/data/pg_hba.conf
cat <<EOF >/var/lib/postgresql/data/pg_hba.conf
# PostgreSQL Client Authentication Configuration File
# ===================================================
#
# Database administrative login by Unix domain socket
local   all             postgres                                md5

# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     md5
# IPv4 local connections:
host    all             all             127.0.0.1/32            md5
# IPv6 local connections:
host    all             all             ::1/128                 md5
# Allow replication connections from localhost, by a user with the
# replication privilege.
local   replication     all                                     peer
host    replication     all             127.0.0.1/32            md5
host    replication     all             ::1/128                 md5
# Allow access from Internet
host    all             all             0.0.0.0/0               md5
host    all             all             ::/0                    md5
EOF
### ??? chown postgres:postgres /var/lib/postgresql/data/pg_hba.conf

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/postgresql/data/postgresql.conf
su -l postgres -c 'pg_ctl reload -D /var/lib/postgresql/data'

### Supervisor
apk add supervisor
supervisord -c /etc/supervisord.conf

sed -i "s/;\[inet_http_server\]/[inet_http_server]/g" /etc/supervisord.conf
sed -i "s/;port=127.0.0.1/port=*/g" /etc/supervisord.conf
sed -i "s/;username=user/username=???/g" /etc/supervisord.conf
sed -i "s/;password=123/password=???/g" /etc/supervisord.conf

### Java
apk add openjdk11

### Tomcat
VERSION=9.0.62
mkdir /opt/tomcat

wget https://www-eu.apache.org/dist/tomcat/tomcat-9/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz -P /tmp
tar -xf /tmp/apache-tomcat-${VERSION}.tar.gz -C /opt/tomcat/
ln -s /opt/tomcat/apache-tomcat-${VERSION} /opt/tomcat/latest
sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
sed -i "s/8005/8015/g" /opt/tomcat/latest/conf/server.xml

# sample .war
wget https://tomcat.apache.org/tomcat-5.5-doc/appdev/sample/sample.war -P /home/
cp /home/sample.war /opt/tomcat/latest/webapps
/opt/tomcat/latest/bin/startup.sh

##############################
#
# build Docker image:
# ~ time DOCKER_BUILDKIT=1 docker build -t geo-alpine-supervisor .
# 
# run Docker container:
# ~ docker run -d -p <for_tomcat>:8080 -p <for_supervisor>:9001 geo-alpine-supervisor
# ~ docker run -d -p 80:8080 -p 9999:9001 geo-alpine-supervisor
#
# accessing:
# localhost:<for_tomcat>/sample
# localhost:<for_supervisor>
# OR
# public-ip-of-vm:<for_tomcat>/sample
# public-ip-of-vm:<for_supervisor>
#
##############################