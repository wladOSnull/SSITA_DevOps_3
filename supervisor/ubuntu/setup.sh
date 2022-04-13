#!/bin/bash

##################################################
#
# This is a bash script for cofiguring independent 
# geocitizen docker image - Tomcat+PostgreSQL
#
##################################################

# common
apt update
apt install -y supervisor wget less nano net-tools sudo

# apache2
apt install -y apache2
mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor

# java
apt install -y openjdk-11-jdk
ln -s /usr/lib/jvm/java-1.11.0-openjdk-amd64 /usr/lib/jvm/default-java

# tomcat
useradd -m -U -d /opt/tomcat -s /bin/false tomcat
VERSION=9.0.62

wget https://www-eu.apache.org/dist/tomcat/tomcat-9/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz -P /tmp
tar -xf /tmp/apache-tomcat-${VERSION}.tar.gz -C /opt/tomcat/
ln -s /opt/tomcat/apache-tomcat-${VERSION} /opt/tomcat/latest
sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
sed -i "s/8005/8015/g" /opt/tomcat/latest/conf/server.xml

# sample .war
wget https://tomcat.apache.org/tomcat-5.5-doc/appdev/sample/sample.war -P /home/
cp /home/sample.war /opt/tomcat/latest/webapps

# postgresql
apt install -y postgresql postgresql-contrib
pg_ctlcluster 12 main start

sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
sudo -u postgres psql -c "CREATE USER geocitizen WITH PASSWORD 'weakpass';"
sudo -u postgres psql -c "ALTER USER geocitizen CREATEDB;"
sudo -u postgres psql -c "CREATE DATABASE ss_demo_1;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE ss_demo_1 to geocitizen;"

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/12/main/postgresql.conf
sed -i "s/auto/manual/g" /etc/postgresql/12/main/start.conf

/etc/init.d/postgresql restart