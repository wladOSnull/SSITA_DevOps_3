# main
FROM alpine:latest
MAINTAINER wlados

# for confguring image
COPY --chmod=777 ./build.sh /home/build.sh
RUN ./home/build.sh

# for PostgreSQL connection
COPY --chmod=777 ./postgres_custom.sh /usr/local/bin/postgres_custom.sh

# for configuring supervisor daemon
COPY ./supervisord.conf /etc/supervisor.d/supervisord.ini

# for storing
COPY ./geocit134.sh /home/geocit134.sh

# for deploying Geo Citizen
COPY ./citizen.war /opt/tomcat/latest/webapps/citizen.war

# for PostgreSQL, Tomcat, Supervisord Web interface, Apache2
EXPOSE 8080 9001

# for starting supervisor daemon as main process
CMD ["/usr/bin/supervisord"]
